defmodule ElvesOfLive do
  def read_file() do
    File.read!("./years/aoc2022/input/23.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(
      %{
        :max_y => 0,
        :min_y => 1000,
        :max_x => 0,
        :min_x => 1000
      },
      fn {values, y}, map ->
        values
        |> String.trim("\n")
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(map, fn {pos_value, x}, acc ->
          case pos_value do
            "#" ->
              Map.put(acc, {x, y}, "#")
              |> Map.put(:max_y, max(acc.max_y, y))
              |> Map.put(:max_x, max(acc.max_x, x))
              |> Map.put(:min_y, min(acc.min_y, y))
              |> Map.put(:min_x, min(acc.min_x, x))

            _ ->
              acc
          end
        end)
      end
    )
    |> print_map()
  end

  def get_next_start_dir("N"), do: "S"
  def get_next_start_dir("S"), do: "W"
  def get_next_start_dir("W"), do: "E"
  def get_next_start_dir("E"), do: "N"

  def get_checks(_dir, acc) when length(acc) == 4, do: acc |> Enum.reverse()

  def get_checks(dir, acc) do
    next = get_next_start_dir(dir)
    get_checks(next, [dir | acc])
  end

  def coords("N"), do: [{0, -1}, {-1, -1}, {1, -1}]
  def coords("S"), do: [{0, 1}, {-1, 1}, {1, 1}]
  def coords("W"), do: [{-1, 0}, {-1, -1}, {-1, 1}]
  def coords("E"), do: [{1, 0}, {1, -1}, {1, 1}]

  def get_next_pos({x, y}, [], _map), do: {x, y}

  def get_next_pos({x, y}, [cur_check | rest], map) do
    coords_to_check = coords(cur_check)

    case Enum.all?(coords_to_check, fn {x1, y1} ->
           Map.get(map, {x + x1, y + y1}, nil)  == nil
         end) do
      true ->
        cond do
          length(rest) == 3 ->
            other_coords =
              Enum.map(rest, fn x -> coords(x) end)
              |> List.flatten()
              |> MapSet.new()
              |> MapSet.to_list()

            case Enum.all?(other_coords, fn {x1, y1} ->
                   Map.get(map, {x + x1, y + y1}, nil) == nil
                 end) do
              true ->
                # IO.inspect({x, y}, label: "done")
                {x, y}

              false ->
                [{x1, y1} | _] = coords_to_check
                {x + x1, y + y1}
            end

          true ->
            [{x1, y1} | _] = coords_to_check
            {x + x1, y + y1}
        end

      false ->
        get_next_pos({x, y}, rest, map)
    end
  end

  def step(map, cur_start_dir) do
    next_map_with_collisions =
      map
      |> Map.to_list()
      |> Enum.reduce(%{}, fn
        {key, _}, acc when key in [:max_y, :min_y, :max_x, :min_x] ->
          acc

        {{x, y}, _}, acc ->
          next_pos = get_next_pos({x, y}, get_checks(cur_start_dir, []), map)
          # if {x, y} != next_pos, do: IO.inspect({{x, y}, next_pos}, label: "move")

          Map.update(acc, next_pos, {1, [{x, y}]}, fn {count, prev_pos_list} ->
            {count + 1, [{x, y} | prev_pos_list]}
          end)
      end)

      next_map_with_collisions
      |> Map.to_list()
      |> Enum.reduce(
        %{
          :max_y => -1000,
          :min_y => 1000,
          :max_x => -1000,
          :min_x => 1000
        },
        fn {{x, y}, {count, prev_positions}}, acc ->
          case count do
            1 ->
              Map.put(acc, {x, y}, "#")
              |> Map.put(:max_y, max(acc.max_y, y))
              |> Map.put(:max_x, max(acc.max_x, x))
              |> Map.put(:min_y, min(acc.min_y, y))
              |> Map.put(:min_x, min(acc.min_x, x))

            _ ->
              Enum.reduce(prev_positions, acc, fn {x1, y1}, int_acc ->
                Map.put(int_acc, {x1, y1}, "#")
                |> Map.put(:max_y, max(int_acc.max_y, y1))
                |> Map.put(:max_x, max(int_acc.max_x, x1))
                |> Map.put(:min_y, min(int_acc.min_y, y1))
                |> Map.put(:min_x, min(int_acc.min_x, x1))
              end)
          end
        end
      )
  end

  def get_row({x, y}, map, acc) when x > map.max_x or y > map.max_y,
    do: Enum.reverse(acc)

  def get_row({x, y}, map, acc) when x <= map.max_x do
    val =
      case Map.get(map, {x, y}) do
        nil -> "."
        value -> value
      end

    get_row({x + 1, y}, map, [val | acc])
  end

  def get_rows(y, map, acc) do
    case get_row({map.min_x, y}, map, []) do
      [] -> Enum.reverse(acc)
      row -> get_rows(y + 1, map, [row | acc])
    end
  end

  def print_map(map) do
    get_rows(map.min_y, map, [])
    |> Enum.map_join("\n", fn row -> Enum.join(row, "") end)
    |> IO.puts()

    IO.puts("")

    map
  end

  def solve1 do
    map = read_file()

    {last_map, _} =
      1..10
      |> Enum.reduce({map, "N"}, fn i, {acc_map, cur_start_dir} ->
        IO.inspect(i)
        new_map = step(acc_map, cur_start_dir)
        next_start_dir = get_next_start_dir(cur_start_dir)
        {new_map, next_start_dir}
      end)
      |> IO.inspect()

    count =
      last_map
      |> Map.to_list()
      |> Enum.filter(fn {k, _} -> k not in [:max_y, :min_y, :max_x, :min_x] end)
      |> length()
      |> IO.inspect()

    (last_map.max_x - last_map.min_x) * (last_map.max_y - last_map.min_y) - count
  end

  def normalize(map) do
    diff_y = -map.min_y
    diff_x = -map.min_x

    map
    |> Map.to_list()
    |> Enum.reduce(
      %{
        :max_y => map.max_y + diff_y,
        :min_y => 0,
        :max_x => map.max_x + diff_x,
        :min_x => 0
      },
      fn
        {key, _v}, acc when key in [:max_y, :min_y, :max_x, :min_x] ->
          acc

        {{x, y}, _}, acc ->
          Map.put(acc, {x + diff_x, y + diff_y}, "#")
      end
    )
  end

  def solve2 do
    map = read_file()

    1..2100
    |> Enum.reduce_while({map, "N"}, fn i, {acc_map, cur_start_dir} ->
      IO.inspect({cur_start_dir, i})

      new_map =
        step(acc_map, cur_start_dir)
        # |> print_map()

      # |> normalize()

      next_start_dir = get_next_start_dir(cur_start_dir)

      cond do
        Map.equal?(new_map, acc_map) -> {:halt, {new_map, i}}
        true -> {:cont, {new_map, next_start_dir}}
      end
    end)
  end
end

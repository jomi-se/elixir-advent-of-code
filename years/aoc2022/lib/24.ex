defmodule Blizz do
  def read_file() do
    {map, bliz} =
      File.read!("./years/aoc2022/input/24.txt")
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(
        {%{
           :max_y => 0,
           :min_y => 1000,
           :max_x => 0,
           :min_x => 1000
         }, []},
        fn {values, y}, {map, blizzards} ->
          values
          |> String.trim("\n")
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce({map, blizzards}, fn {pos_value, x}, {accc_map, acc_bliz} ->
            case pos_value do
              "#" ->
                {Map.put(accc_map, {x, y}, "#")
                 |> Map.put(:max_y, max(accc_map.max_y, y))
                 |> Map.put(:max_x, max(accc_map.max_x, x))
                 |> Map.put(:min_y, min(accc_map.min_y, y))
                 |> Map.put(:min_x, min(accc_map.min_x, x)), acc_bliz}

              bliz_dir when bliz_dir in [">", "<", "^", "v"] ->
                {accc_map, [{{x, y}, bliz_dir} | acc_bliz]}

              _ ->
                {accc_map, acc_bliz}
            end
          end)
        end
      )
      |> print_map()

    {Map.put(map, :start, {1, 0}) |> Map.put(:end, {map.max_x - 1, map.max_y}), bliz}
  end

  def bliz_next_pos({{x, y}, "^"}, map) do
    next_pos = {x, y - 1}

    case Map.get(map, next_pos, nil) do
      "#" -> {{x, map.max_y - 1}, "^"}
      _ -> {next_pos, "^"}
    end
  end

  def bliz_next_pos({{x, y}, ">"}, map) do
    next_pos = {x + 1, y}

    case Map.get(map, next_pos, nil) do
      "#" -> {{map.min_x + 1, y}, ">"}
      _ -> {next_pos, ">"}
    end
  end

  def bliz_next_pos({{x, y}, "<"}, map) do
    next_pos = {x - 1, y}

    case Map.get(map, next_pos, nil) do
      "#" -> {{map.max_x - 1, y}, "<"}
      _ -> {next_pos, "<"}
    end
  end

  def bliz_next_pos({{x, y}, "v"}, map) do
    next_pos = {x, y + 1}

    case Map.get(map, next_pos, nil) do
      "#" -> {{x, map.min_y + 1}, "v"}
      _ -> {next_pos, "v"}
    end
  end

  def get_next_bliz_pos([], _map, acc), do: acc

  def get_next_bliz_pos([bliz | rest], map, acc) do
    get_next_bliz_pos(rest, map, [bliz_next_pos(bliz, map) | acc])
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

  def get_blizz_map(bliz) do
    Enum.reduce(bliz, %{}, fn {bliz_pos, bliz_dir}, acc ->
      Map.update(acc, bliz_pos, bliz_dir, fn
        count when is_integer(count) -> count + 1
        _bliz_dir -> 2
      end)
    end)
  end

  def print_map({map, bliz}) do
    bliz_map = get_blizz_map(bliz)

    map_to_print = Map.merge(map, bliz_map)

    get_rows(map.min_y, map_to_print, [])
    |> Enum.map_join("\n", fn row -> Enum.join(row, "") end)
    |> IO.puts()

    IO.puts("")

    {map, bliz}
  end

  def check_if_done([], _grid), do: {:continue, nil}

  def check_if_done([{x, y} | pos_list_rest], map) do
    cond do
      {x, y} == map.end -> {:done, {x, y}}
      true -> check_if_done(pos_list_rest, map)
    end
  end

  def in_bounds({x, y}, map),
    do: x <= map.max_x and x >= map.min_x and y >= map.min_y and y <= map.max_y

  def get_next_step_positions(positions, {map, blizz}) do
    next_blizz = get_next_bliz_pos(blizz, map, [])
    next_blizz_map = get_blizz_map(next_blizz)

    next_positions =
      Enum.map(positions, fn {x, y} ->
        [
          {0, 0},
          {1, 0},
          {-1, 0},
          {0, 1},
          {0, -1}
        ]
        |> Enum.map(fn {x1, y1} -> {x + x1, y + y1} end)
        |> Enum.filter(fn pos ->
          Map.get(map, pos) != "#" and not Map.has_key?(next_blizz_map, pos) and
            in_bounds(pos, map)
        end)
      end)
      |> List.flatten()
      |> MapSet.new()
      |> MapSet.to_list()

    {next_positions, next_blizz}
  end

  # With BFS without keeping track of the path we can figure out the distance
  # to destination without exploding the memory
  def bfs_search_step({map, bliz}, steps_queue, step_count) do
    {{:value, next_positions}, steps_queue_popped} = :queue.out(steps_queue)

    # Check if done
    case check_if_done(next_positions, map) do
      {:done, _} ->
        {:done, step_count, {map, bliz}}

      {:continue, _} ->
        new_step_count = step_count + 1

        {next_step_positions, next_bliz} = get_next_step_positions(next_positions, {map, bliz})

        new_steps_queue = :queue.in(next_step_positions, steps_queue_popped)
        bfs_search_step({map, next_bliz}, new_steps_queue, new_step_count)
    end
  end

  def solve1 do
    {map, bliz} = read_file()

    bfs_search_step({map, bliz}, :queue.from_list([[map.start]]), 0)
  end

  def solve2 do
    {map, bliz} = read_file()

    {:done, count_1, {_map, new_bliz}} =
      bfs_search_step({map, bliz}, :queue.from_list([[map.start]]), 0)

    map_back = Map.put(map, :end, map.start)

    {:done, count_2, {_map, new_bliz_2}} =
      bfs_search_step({map_back, new_bliz}, :queue.from_list([[map.end]]), 0)

    {:done, count_3, _} = bfs_search_step({map, new_bliz_2}, :queue.from_list([[map.start]]), 0)

    count_1 + count_2 + count_3
  end
end

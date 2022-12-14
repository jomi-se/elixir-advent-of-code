defmodule Origami do
  def read_file() do
    {:ok, contents} = File.read("./years/aoc2021/input/13.txt")

    [points, folds] = String.split(contents, "\n\n", trim: true)

    map =
      points
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{:max_y => 0, :max_x => 0}, fn str, acc_map ->
        [x, y] = String.split(str, ",") |> Enum.map(&String.to_integer(&1))

        Map.put(acc_map, {x, y}, "█")
        |> Map.put(:max_y, max(y, acc_map.max_y))
        |> Map.put(:max_x, max(x, acc_map.max_x))
      end)

    folds_parsed =
      folds
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        "fold along " <> fold = str

        case fold do
          "x=" <> val -> {"x", String.to_integer(val)}
          "y=" <> val -> {"y", String.to_integer(val)}
        end
      end)

    {map, folds_parsed}
  end

  def do_fold({"x", value}, map) do
    Map.to_list(map)
    |> Enum.reduce(%{:max_y => 0, :max_x => 0}, fn {key, val}, acc_map ->
      case key do
        :max_x ->
          acc_map

        :max_y ->
          acc_map

        {x, y} ->
          cond do
            x <= value ->
              Map.put(acc_map, {x, y}, val)
              |> Map.put(:max_y, max(y, acc_map.max_y))
              |> Map.put(:max_x, max(x, acc_map.max_x))

            true ->
              dist = abs(x - value)
              new_x = value - dist

              Map.put(acc_map, {new_x, y}, val)
              |> Map.put(:max_y, max(y, acc_map.max_y))
              |> Map.put(:max_x, max(new_x, acc_map.max_x))
          end
      end
    end)
  end

  def do_fold({"y", value}, map) do
    Map.to_list(map)
    |> Enum.reduce(%{:max_y => 0, :max_x => 0}, fn {key, val}, acc_map ->
      case key do
        :max_x ->
          acc_map

        :max_y ->
          acc_map

        {x, y} ->
          cond do
            y <= value ->
              Map.put(acc_map, {x, y}, val)
              |> Map.put(:max_y, max(y, acc_map.max_y))
              |> Map.put(:max_x, max(x, acc_map.max_x))

            true ->
              dist = abs(y - value)
              new_y = value - dist

              Map.put(acc_map, {x, new_y}, val)
              |> Map.put(:max_y, max(new_y, acc_map.max_y))
              |> Map.put(:max_x, max(x, acc_map.max_x))
          end
      end
    end)
  end

  def get_row({x, y}, map, acc) when x > map.max_x or y > map.max_y,
    do: Enum.reverse(acc)

  def get_row({x, y}, map, acc) when x <= map.max_x + 10 do
    val =
      case Map.get(map, {x, y}) do
        nil -> "."
        value -> value
      end

    get_row({x + 1, y}, map, [val | acc])
  end

  def get_rows(y, map, acc) do
    case get_row({0, y}, map, []) do
      [] -> Enum.reverse(acc)
      row -> get_rows(y + 1, map, [row | acc])
    end
  end

  def print_map(map) do
    get_rows(0, map, [])
    |> Enum.map_join("\n", fn row -> Enum.join(row, "") end)
    |> IO.puts()

    IO.puts("")

    map
  end

  def solve1 do
    {map, folds} = read_file()

    print_map(map)

    [first_fold | _rest] = folds

    new =
      do_fold(first_fold, map)
      |> print_map()
      |> map_size()

    new - 2
  end

  def solve2 do
    {map, folds} = read_file()

    print_map(map)

    Enum.reduce(folds, map, fn fold, acc_map ->
      do_fold(fold, acc_map)
      |> print_map()
    end)
    |> map_size()
  end
end

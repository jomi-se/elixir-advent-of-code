defmodule Regolith do
  def read_file do
    File.read!("./years/aoc2022/input/14.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ", trim: true)
      |> Enum.map(fn coords_str ->
        [x, y] = String.split(coords_str, ",") |> Enum.map(&String.to_integer(&1))
        {x, y}
      end)
    end)
  end

  def build_rock_line([], map), do: map
  def build_rock_line([_line_end], map), do: map

  def build_rock_line([line_start, line_end | rest], map) do
    {xs, ys} = line_start
    {xe, ye} = line_end

    acc_map =
      map
      |> Map.put(:min_x, min(map.min_x, min(xs, xe)))
      |> Map.put(:max_x, max(map.max_x, max(xs, xe)))
      |> Map.put(:min_y, min(map.min_y, min(ys, ye)))
      |> Map.put(:max_y, max(map.max_y, max(ys, ye)))

    next_map =
      cond do
        xs == xe -> for y <- ys..ye, into: acc_map, do: {{xs, y}, "#"}
        ys == ye -> for x <- xs..xe, into: acc_map, do: {{x, ys}, "#"}
      end

    build_rock_line([line_end | rest], next_map)
  end

  def build_map([], map), do: map

  def build_map([rock_line | rest_rock_lines], map) do
    acc_map = build_rock_line(rock_line, map)
    build_map(rest_rock_lines, acc_map)
  end

  def get_row({x, y}, map, acc) when x > map.max_x + 2 or y > map.max_y + 3, do: Enum.reverse(acc)

  def get_row({x, y}, map, acc) when x <= map.max_x + 2 do
    val =
      case Map.get(map, {x, y}) do
        nil -> "."
        _value -> "#"
      end

    get_row({x + 1, y}, map, [val | acc])
  end

  def get_rows(y, map, acc) do
    case get_row({map.min_x - 2, y}, map, []) do
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
    read_file()
    |> build_map(%{:min_x => 1_000_000, :max_x => 0, :min_y => 10_000_000, :max_y => 0})
    |> print_map()
  end
end

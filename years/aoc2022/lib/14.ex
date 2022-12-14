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

  def find_next_sand_spot({_cur_x, cur_y}, map) when cur_y > map.max_y, do: {:halt, map}

  def find_next_sand_spot({cur_x, cur_y}, map) do
    pos_val = Map.get(map, {cur_x, cur_y})

    if pos_val == "#" do
      raise "Error with this position, should not be here: #{cur_x}, #{cur_y}"
    end

    cond do
      pos_val == "o" ->
        {:halt, map}

      Map.get(map, {cur_x, cur_y + 1}) == nil ->
        find_next_sand_spot({cur_x, cur_y + 1}, map)

      Map.get(map, {cur_x - 1, cur_y + 1}) == nil ->
        find_next_sand_spot({cur_x - 1, cur_y + 1}, map)

      Map.get(map, {cur_x + 1, cur_y + 1}) == nil ->
        find_next_sand_spot({cur_x + 1, cur_y + 1}, map)

      true ->
        {:cont, Map.put(map, {cur_x, cur_y}, "o")}
    end
  end

  def get_row({x, y}, map, acc) when x > map.max_x + 10 or y > map.max_y + 5,
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
    case get_row({map.min_x - 10, y}, map, []) do
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

  def step_sand(map, {sand_x, sand_y}, count) do
    case find_next_sand_spot({sand_x, sand_y}, map) do
      {:cont, next_map} ->
        # print_map(next_map)
        next_map
        |> step_sand({sand_x, sand_y}, count + 1)

      {:halt, _last_map} ->
        # print_map(last_map)
        count
    end
  end

  def solve1 do
    read_file()
    |> build_map(%{:min_x => 1_000_000, :max_x => 0, :min_y => 10_000_000, :max_y => 0})
    |> step_sand({500, 0}, 0)
  end

  def solve2 do
    base_map =
      read_file()
      |> build_map(%{:min_x => 1_000_000, :max_x => 0, :min_y => 10_000_000, :max_y => 0})

    map_with_floor =
      -500..2000
      |> Enum.reduce(base_map, fn x, acc_map -> Map.put(acc_map, {x, acc_map.max_y + 2}, "#") end)

    map_with_floor
    |> Map.put(:max_y, map_with_floor.max_y + 2)
    |> step_sand({500, 0}, 0)
  end
end

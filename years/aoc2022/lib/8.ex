defmodule TreeHouse do
  def read_file() do
    File.read!("./years/aoc2022/input/8.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {values, y}, map ->
      values
      |> String.trim("\n")
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {pos_value, x}, acc ->
        Map.put(acc, {x, y}, String.to_integer(pos_value))
        |> Map.put(:max_y, y)
        |> Map.put(:max_x, x)
      end)
    end)
  end

  def check_visibility([], _value, _map), do: true

  def check_visibility([pos | rest], value, map) do
    case Map.fetch!(map, pos) < value do
      true -> check_visibility(rest, value, map)
      false -> false
    end
  end

  def is_visible({x, y}, map) do
    value = Map.fetch!(map, {x, y})

    positions_y1 =
      for x1 <- 0..x,
          x1 != x,
          do: {x1, y}

    positions_y2 =
      for x1 <- x..map.max_x,
          x1 != x,
          do: {x1, y}

    positions_x1 =
      for y1 <- 0..y,
          y1 != y,
          do: {x, y1}

    positions_x2 =
      for y1 <- y..map.max_y,
          y1 != y,
          do: {x, y1}

    check_visibility(positions_x1, value, map) or
      check_visibility(positions_x2, value, map) or
      check_visibility(positions_y1, value, map) or
      check_visibility(positions_y2, value, map)
  end

  def count_visible_in_map(map) do
    for x <- 0..map.max_x, y <- 0..map.max_y do
      cond do
        x == 0 or x == map.max_y or y == 0 or y == map.max_y or
            is_visible({x, y}, map) ->
          1

        true ->
          0
      end
    end
    |> Enum.sum()
  end

  def solve1 do
    map = read_file()

    count_visible_in_map(map)
  end

  def compute_scenic_score([], _value, _map, acc), do: acc

  def compute_scenic_score([pos | rest], value, map, acc) do
    case Map.fetch!(map, pos) < value do
      true -> compute_scenic_score(rest, value, map, acc + 1)
      false -> acc + 1
    end
  end

  def get_scenic_score({x, y}, map) do
    value = Map.fetch!(map, {x, y})

    positions_y1 =
      for x1 <- x..0,
          x1 != x,
          do: {x1, y}

    positions_y2 =
      for x1 <- x..map.max_x,
          x1 != x,
          do: {x1, y}

    positions_x1 =
      for y1 <- y..0,
          y1 != y,
          do: {x, y1}

    positions_x2 =
      for y1 <- y..map.max_y,
          y1 != y,
          do: {x, y1}

    compute_scenic_score(positions_x1, value, map, 0) *
      compute_scenic_score(positions_x2, value, map, 0) *
      compute_scenic_score(positions_y1, value, map, 0) *
      compute_scenic_score(positions_y2, value, map, 0)
  end

  def get_scenic_scores_in_map(map) do
    for x <- 0..map.max_x, y <- 0..map.max_y, into: %{} do
      cond do
        x == 0 or x == map.max_y or y == 0 or y == map.max_y ->
          {{x, y}, 0}

        true ->
          {{x, y}, get_scenic_score({x, y}, map)}
      end
    end
  end

  def solve2 do
    [max] =
      read_file()
      |> get_scenic_scores_in_map()
      |> Map.to_list()
      |> Enum.map(fn {_, val} -> val end)
      |> Enum.sort(fn a, b -> a > b end)
      |> Enum.take(1)

    max
  end
end

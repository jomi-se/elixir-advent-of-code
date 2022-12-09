defmodule SmokeBasin do
  def read_file!() do
    File.read!("./years/aoc2021/input/9.txt")
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

  def is_low_point({x, y}, map) do
    value = Map.fetch!(map, {x, y})

    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.all?(fn {x1, y1} ->
      case Map.get(map, {x1, y1}) do
        nil -> true
        value1 -> value < value1
      end
    end)
  end

  def count_low_points_risk(map) do
    for x <- 0..map.max_x, y <- 0..map.max_y do
      cond do
        is_low_point({x, y}, map) ->
          Map.fetch!(map, {x, y}) + 1

        true ->
          0
      end
    end
    |> Enum.sum()
  end

  def solve1 do
    map = read_file!()
    count_low_points_risk(map)
  end

  def compute_basin_size({x, y}, map, visited_map, size) do

    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.reduce({visited_map, size}, fn {x1, y1}, {acc_visited_map, acc_size} ->
      is_visited = Map.get(acc_visited_map, {x1, y1})
      value = Map.get(map, {x1, y1})

      {_next_acc_vis_map, _next_acc_size} =
        cond do
          is_visited != nil or value == nil ->
            {acc_visited_map, acc_size}

          value == 9 ->
            {Map.put(acc_visited_map, {x1, y1}, true), acc_size}

          true ->
            compute_basin_size(
              {x1, y1},
              map,
              Map.put(acc_visited_map, {x1, y1}, true),
              acc_size + 1
            )
        end
    end)
  end

  def count_low_points_basin_sizes(map) do
    for x <- 0..map.max_x, y <- 0..map.max_y do
      cond do
        is_low_point({x, y}, map) ->
          {_, size} = compute_basin_size({x, y}, map, %{{x, y} => true}, 1)
          size

        true ->
          1
      end
    end
    |> Enum.sort(fn a,b -> a>=b end)
    |> Enum.take(3)
    |> Enum.product()
  end

  def solve2 do
    read_file!()
    |> count_low_points_basin_sizes()
  end
end

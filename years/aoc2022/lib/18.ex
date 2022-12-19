defmodule Obsidian do
  def read_file() do
    File.read!("./years/aoc2022/input/18.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer(&1))
      {{x, y, z}, true}
    end)
    |> Map.new()
  end

  def count_free_sides({x, y, z}, map) do
    t = [{1, 0, 0}, {0, 1, 0}, {0, 0, 1}, {-1, 0, 0}, {0, -1, 0}, {0, 0, -1}]
    adjacent_sides = t |> Enum.map(fn {x1, y1, z1} -> {x + x1, y + y1, z + z1} end)

    Enum.reduce(adjacent_sides, 0, fn pos, acc ->
      case Map.get(map, pos) do
        true -> acc
        _ -> acc + 1
      end
    end)
  end

  def solve1() do
    map = read_file()

    map
    |> Map.to_list()
    |> Enum.map(fn {pos, _} -> count_free_sides(pos, map) end)
    |> Enum.sum()
  end

  def is_out_of_bounds({x, y, z}, map) do
    x > map.max_x or
      x < map.min_x or
      y > map.max_y or
      y < map.min_y or
      z > map.max_z or
      z < map.min_z
  end

  def get_adjacent_blocks({x, y, z}) do
    t = [{1, 0, 0}, {0, 1, 0}, {0, 0, 1}, {-1, 0, 0}, {0, -1, 0}, {0, 0, -1}]
    t |> Enum.map(fn {x1, y1, z1} -> {x + x1, y + y1, z + z1} end)
  end

  def fill_surrounding(queue, visited_map, original_map) do
    case :queue.out(queue) do
      {{:value, {x, y, z}}, rest_queue} ->
        cond do
          is_out_of_bounds({x, y, z}, original_map) ->
            original_map

          true ->
            blocks_to_fill =
              get_adjacent_blocks({x, y, z})
              |> Enum.filter(fn pos ->
                not Map.has_key?(visited_map, pos) and not Map.has_key?(original_map, pos)
              end)

            new_queue = :queue.join(rest_queue, :queue.from_list(blocks_to_fill))

            new_visited_map =
              blocks_to_fill
              |> Enum.reduce(visited_map, fn {x1, y1, z1}, acc ->
                Map.put(acc, {x1, y1, z1}, true)
              end)

            fill_surrounding(new_queue, new_visited_map, original_map)
        end

      {:empty, _} ->
        Map.merge(original_map, visited_map)
    end
  end

  def try_fill_map(map) do
    map
    |> Map.to_list()
    |> Enum.reduce(map, fn
      {{x, y, z}, _}, acc_map ->
        get_adjacent_blocks({x, y, z})
        |> Enum.filter(fn pos ->
          not Map.has_key?(acc_map, pos)
        end)
        |> Enum.reduce(acc_map, fn adj_pos, acc_map_int ->
          fill_surrounding(:queue.from_list([adj_pos]), %{adj_pos => true}, acc_map_int)
        end)

      {a, _num}, acc_map when is_atom(a) ->
        acc_map
    end)
  end

  def solve2 do
    map = read_file()

    map_with_bounds =
      map
      |> Map.to_list()
      |> Enum.reduce(
        %{
          :min_x => 1000,
          :max_x => -1,
          :min_y => 1000,
          :max_y => -10,
          :min_z => 1000,
          :max_z => -10
        },
        fn
          {{x, y, z}, _}, acc_map ->
            acc_map
            |> Map.put({x, y, z}, true)
            |> Map.put(:min_x, min(x, acc_map.min_x))
            |> Map.put(:max_x, max(x, acc_map.max_x))
            |> Map.put(:min_y, min(y, acc_map.min_y))
            |> Map.put(:max_y, max(y, acc_map.max_y))
            |> Map.put(:min_z, min(z, acc_map.min_z))
            |> Map.put(:max_z, max(z, acc_map.max_z))
        end
      )

    filled_map = try_fill_map(map_with_bounds)

    filled_map
    |> Map.to_list()
    |> Enum.filter(fn {x, _} -> not is_atom(x) end)
    |> Enum.map(fn
      {pos, _} -> count_free_sides(pos, filled_map)
    end)
    |> Enum.sum()
  end
end

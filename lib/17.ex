defmodule EnergyStuff do
  def read_map_from_file() do
    {:ok, contents} = File.read("input/17.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {values, y}, map ->
      values
      |> String.trim("\n")
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {pos_value, x}, acc ->
        Map.put(acc, {x, y, 0}, pos_value)
        |> Map.put(:max_y, y)
        |> Map.put(:max_x, x)
      end)
    end)
  end

  def step_map(map, size) do
    for x <- (0 - size)..(map.max_x + size),
        y <- (0 - size)..(map.max_y + size),
        z <- -size..size,
        into: %{
          :max_y => map.max_y,
          :max_x => map.max_x
        } do
      case(Map.get(map, {x, y, z})) do
        "." -> check_inactive(map, {x, y, z})
        "#" -> check_active(map, {x, y, z})
        _ -> check_inactive(map, {x, y, z})
      end
    end
  end

  def get_surrounding_coordinates({pos_x, pos_y, pos_z}) do
    for x <- (pos_x - 1)..(pos_x + 1),
        y <- (pos_y - 1)..(pos_y + 1),
        z <- (pos_z - 1)..(pos_z + 1),
        z != pos_z or y != pos_y or x != pos_x,
        do: {x, y, z}
  end

  def count_active(coord_list, map) do
    coord_list
    |> Enum.count(fn {x, y, z} ->
      Map.get(map, {x, y, z}) == "#"
    end)
  end

  def count_surrounding_active(map, coords) do
    get_surrounding_coordinates(coords)
    |> count_active(map)
  end

  def check_inactive(map, {pos_x, pos_y, pos_z}) do
    case count_surrounding_active(map, {pos_x, pos_y, pos_z}) do
      3 -> {{pos_x, pos_y, pos_z}, "#"}
      _ -> {{pos_x, pos_y, pos_z}, "."}
    end
  end

  def check_active(map, {pos_x, pos_y, pos_z}) do
    case count_surrounding_active(map, {pos_x, pos_y, pos_z}) do
      count when count == 2 or count == 3 -> {{pos_x, pos_y, pos_z}, "#"}
      _ -> {{pos_x, pos_y, pos_z}, "."}
    end
  end

  def count_all(map) do
    Map.keys(map)
    |> Enum.filter(fn key -> key != :max_x and key != :max_y end)
    |> count_active(map)
  end

  def part_1 do
    first_map = read_map_from_file()

    last_map =
      1..6
      |> Enum.reduce(first_map, fn _, map ->
        step_map(map, 6)
      end)

    count_all(last_map)
  end
end

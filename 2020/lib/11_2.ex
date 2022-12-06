defmodule SeatsMap_2 do
  def read_map_from_file!() do
    {:ok, contents} = File.read("input/11.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {values, y}, map ->
      values
      |> String.trim("\n")
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {pos_value, x}, acc ->
        Map.put(acc, {x, y}, pos_value)
        |> Map.put(:max_y, y)
        |> Map.put(:max_x, x)
      end)
    end)
  end

  def step_map(map) do
    for x <- 0..map.max_x, y <- 0..map.max_y, into: %{} do
      case(Map.get(map, {x, y})) do
        "." -> {{x, y}, "."}
        "L" -> check_empty_seat(map, {x, y})
        "#" -> check_occupied_seat(map, {x, y})
      end
    end
    |> Map.put(:max_y, map.max_y)
    |> Map.put(:max_x, map.max_x)
  end

  def get_all_directions() do
    for x <- -1..1,
        y <- -1..1,
        x != 0 || y != 0,
        do: {x, y}
  end

  def get_first_in_dir({dir_x, dir_y}, map, {x, y}) do
    next = {x + dir_x, y + dir_y}

    case Map.get(map, next) do
      "." -> get_first_in_dir({dir_x, dir_y}, map, next)
      nil -> "."
      seat -> seat
    end
  end

  def check_empty_seat(map, {pos_x, pos_y}) do
    count = get_all_directions()
    |> Enum.map(&(get_first_in_dir(&1, map, {pos_x, pos_y})))
    |> Enum.count(&(&1 == "#"))

    case count do
      0 -> {{pos_x, pos_y}, "#"}
      _ -> {{pos_x, pos_y}, "L"}
      end
  end

  def check_occupied_seat(map, {pos_x, pos_y}) do
    count = get_all_directions()
    |> Enum.map(&(get_first_in_dir(&1, map, {pos_x, pos_y})))
    |> Enum.count(&(&1 == "#"))

    case count do
      n when n >= 5 -> {{pos_x, pos_y}, "L"}
      _ -> {{pos_x, pos_y}, "#"}
      end
  end

  def count_occupied(map) do
    all = for x <- 0..map.max_x, y <- 0..map.max_y, do: {x, y}

    Enum.count(all, &(Map.get(map, &1) == "#"))
  end

  def solve_until_no_changes(map) do
    map
    |> print_map()
    |> IO.puts()

    next_map = step_map(map)

    case Map.equal?(map, next_map) do
      true -> count_occupied(next_map)
      false -> solve_until_no_changes(next_map)
    end
  end

  def print_map(map) do
    0..map.max_y
    |> Enum.reduce("", fn y, acc_y ->
      line =
        0..map.max_x
        |> Enum.map(&Map.get(map, {&1, y}))
        |> List.to_string()

      acc_y <> line <> "\n"
    end)
  end

  def part_2 do
    read_map_from_file!()
    |> solve_until_no_changes()
  end
end

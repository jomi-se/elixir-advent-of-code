defmodule HydroVent do
  def read_file() do
    {:ok, contents} = File.read("input/5.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn range_str ->
      [{x1, y1}, {x2, y2}] =
        String.split(range_str, " -> ")
        |> Enum.map(fn coords_str ->
          String.split(coords_str, ",")
          |> Enum.map(&String.to_integer(&1))
          |> List.to_tuple()
        end)

      {{x1, y1}, {x2, y2}}
    end)
  end

  def expand_ranges({{x1, y1}, {x2, y2}}) do
    cond do
      x1 == x2 -> Enum.map(y1..y2, &{x1, &1})
      y1 == y2 -> Enum.map(x1..x2, &{&1, y1})
      true -> []
    end
  end

  def superpose_coords([], map), do: map

  def superpose_coords([coords | rest], map) do
    cur_val = Map.get(map, coords, 0)
    new_map = Map.put(map, coords, cur_val + 1)
    superpose_coords(rest, new_map)
  end

  def count_eql_or_larger_than(map, num) do
    Enum.count(map, fn {_, val} -> val >= num end)
  end

  def solve() do
    read_file()
    |> Enum.map(&expand_ranges(&1))
    |> Enum.reduce(fn list, acc -> list ++ acc end)
    |> superpose_coords(%{})
    |> IO.inspect()
    |> count_eql_or_larger_than(2)
  end

  def expand_ranges_with_diag({{x1, y1}, {x2, y2}}) do
    cond do
      x1 == x2 -> Enum.map(y1..y2, &{x1, &1})
      y1 == y2 -> Enum.map(x1..x2, &{&1, y1})
      true -> Enum.zip(x1..x2, y1..y2)
    end
  end

  def solve2 do
    read_file()
    |> Enum.map(&expand_ranges_with_diag(&1))
    |> Enum.reduce(fn list, acc -> list ++ acc end)
    |> superpose_coords(%{})
    |> IO.inspect()
    |> count_eql_or_larger_than(2)
  end
end

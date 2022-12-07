defmodule SectionCleaning do
  def read_file() do
    File.read!("./input/4.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn pair ->
      pair
      |> String.split(",", trim: true)
      |> Enum.map(fn section ->
        [rangeStart, rangeEnd] =
          String.split(section, "-", trim: true) |> Enum.map(&String.to_integer(&1))

        {rangeStart, rangeEnd}
      end)
    end)
  end

  def rangesContainedInOther?([{min1, max1}, {min2, max2}]) when min1 >= min2 and max1 <= max2,
    do: true

  def rangesContainedInOther?([{min1, max1}, {min2, max2}]) when min2 >= min1 and max2 <= max1,
    do: true

  def rangesContainedInOther?(_), do: false

  def solve1() do
    read_file()
    |> Enum.map(fn pairs ->
      case rangesContainedInOther?(pairs) do
        true ->
          1

        false ->
          0
      end
    end)
    |> Enum.sum()
  end

  def rangesContainedInOtherBis?([{min1, max1}, {min2, max2}]) do
    set1 = MapSet.new(min1..max1)
    set2 = MapSet.new(min2..max2)

    intersection_size = MapSet.intersection(set1, set2) |> MapSet.size()
    cond do
      MapSet.size(set1) == intersection_size or MapSet.size(set2) == intersection_size ->
        1

      true ->
        0
    end
  end
  def solve1bis() do
    read_file()
    |> Enum.map(&rangesContainedInOtherBis?(&1))
    |> Enum.sum()
  end

  def rangesOverlap?([{min1, max1}, {min2, max2}]) do
    set1 = MapSet.new(min1..max1)
    set2 = MapSet.new(min2..max2)

    case MapSet.disjoint?(set1, set2) do
      true ->
        0

      false ->
        1
    end
  end

  def solve2 do
    read_file()
    |> Enum.map(&rangesOverlap?(&1))
    |> Enum.sum()
  end
end

defmodule Signal do
  def read_file() do
    File.read!("./input/6.txt")
    |> String.trim()
    |> String.graphemes()
  end

  def check_start_packet4(list, index)

  def check_start_packet4([a1, a2, a3, a4 | rest], index) do
    cond do
      MapSet.size(MapSet.new([a1, a2, a3, a4])) === 4 -> index
      true -> check_start_packet4([a2, a3, a4 | rest], index + 1)
    end
  end

  def solve1() do
    read_file()
    |> check_start_packet4(4)
  end

  def check_start_package_n(list, index, size) do
    [_ | rest] = list
    first_n = Enum.take(list, size)

    cond do
      MapSet.size(MapSet.new(first_n)) === size -> index + size
      true -> check_start_package_n(rest, index + 1, size)
    end
  end

  def solve2() do
    read_file()
    |> check_start_package_n(0, 14)
  end
end

defmodule SubCrabs do
  def read_file() do
    File.read!("./input/7.txt")
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def simple_median(list) do
    Enum.sort(list) |> Enum.at(length(list) |> div(2))
  end

  def get_cost(list, median, acc)
  def get_cost([], _, acc), do: acc
  def get_cost([head | rest], median, acc), do: get_cost(rest, median, acc + abs(head - median))

  def solve do
    list = read_file()
    median = simple_median(list)
    get_cost(list, median, 0)
  end
end

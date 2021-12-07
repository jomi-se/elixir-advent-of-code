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

  def get_weight(num), do: (num * (num + 1)) |> div(2)
  def get_avg(list), do: Enum.sum(list) / length(list)

  def get_weighted_cost(list, median, acc)
  def get_weighted_cost([], _, acc), do: acc

  def get_weighted_cost([head | rest], median, acc),
    do: get_weighted_cost(rest, median, acc + get_weight(abs(head - median)))

  def solve2 do
    list = read_file()
    avg_f = get_avg(list)

    upper = ceil(avg_f)
    lower = floor(avg_f)

    Enum.min([get_weighted_cost(list, upper, 0), get_weighted_cost(list, lower, 0)])
  end
end

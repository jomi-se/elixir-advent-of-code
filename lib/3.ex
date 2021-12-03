defmodule SubmarineConsumption do
  def read_file() do
    {:ok, contents} = File.read("input/3.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn string ->
      String.graphemes(string)
      |> Enum.map(&String.to_integer(&1))
    end)
  end

  def do_sum(list_a, list_b, acc)
  def do_sum([], [], acc), do: Enum.reverse(acc)

  def do_sum([dig_a | rest_a], [dig_b | rest_b], acc) do
    do_sum(rest_a, rest_b, [dig_a + dig_b | acc])
  end

  def sum_by_pos(number, acc)
  def sum_by_pos([], acc), do: acc

  def sum_by_pos([first | rest], acc) do
    new_sum = do_sum(first, acc, [])
    sum_by_pos(rest, new_sum)
  end

  def get_gamma(sum, len) do
    sum
    |> Enum.map(fn dig ->
      cond do
        dig > len / 2 ->
          1

        true ->
          0
      end
    end)
  end

  def get_epsilon(sum, len) do
    sum
    |> Enum.map(fn dig ->
      cond do
        dig <= len / 2 ->
          1

        true ->
          0
      end
    end)
  end

  def solve() do
    [first | rest] = read_file()

    sum =
      sum_by_pos(rest, first)
      |> IO.inspect()

    len = length([first | rest])

    gamma =
      get_gamma(sum, len)
      |> Enum.join()
      |> IO.inspect()
      |> Integer.parse(2)
      |> elem(0)

    epsilon =
      get_epsilon(sum, len)
      |> Enum.join()
      |> IO.inspect()
      |> Integer.parse(2)
      |> elem(0)

    {gamma * epsilon, gamma, epsilon}
  end
end

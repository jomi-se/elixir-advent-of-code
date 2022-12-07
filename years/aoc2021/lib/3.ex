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

  def transpose(list_of_list) do
    Enum.zip(list_of_list) |> Enum.map(&Tuple.to_list/1)
  end

  def get_o2_significant_bit(list, len) do
    sum = list |> Enum.sum()

    cond do
      sum >= len / 2 ->
        1

      true ->
        0
    end
  end

  def get_o2([pick],_), do: pick
  def get_o2(num_list, pos) do
    len = length(num_list)
    digit_list = transpose(num_list)
    sig_dig_list  = Enum.at(digit_list, pos)

    sig_bit =
      get_o2_significant_bit(sig_dig_list, len)

    num_list
    |> Enum.filter(fn num ->
      sig_bit == Enum.at(num, pos)
    end)
    |> get_o2(pos + 1)
  end

  def get_co_significant_bit(list, len) do
    sum = list |> Enum.sum()

    cond do
      sum >= len / 2 ->
        0

      true ->
        1
    end
  end

  def get_co([pick],_), do: pick
  def get_co(num_list, pos) do
    len = length(num_list)
    digit_list = transpose(num_list)
    sig_dig_list  = Enum.at(digit_list, pos)

    sig_bit =
      get_co_significant_bit(sig_dig_list, len)

    num_list
    |> Enum.filter(fn num ->
      sig_bit == Enum.at(num, pos)
    end)
    |> get_co(pos + 1)
  end

  def solve2() do
    num_list = read_file()

    o2 = get_o2(num_list, 0)
      |> Enum.join()
      |> IO.inspect()
      |> Integer.parse(2)
      |> elem(0)

    co = get_co(num_list, 0)
      |> Enum.join()
      |> IO.inspect()
      |> Integer.parse(2)
      |> elem(0)

    {co * o2, co, o2}
  end
end

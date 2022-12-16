defmodule Polymer do
  def read_file() do
    [start, commands] =
      File.read!("./years/aoc2021/input/14.txt")
      |> String.split("\n\n", trim: true)

    start_parsed = start |> String.graphemes()

    commands_map =
      commands
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn line, acc_map ->
        [pair, result] = String.split(line, " -> ", trim: true)
        [first, second] = pair |> String.graphemes()

        Map.put(
          acc_map,
          {first, second},
          result
        )
      end)

    {start_parsed, commands_map}
  end

  def convert_polymer([], _commands_map, acc), do: acc
  def convert_polymer([rest], _commands_map, acc), do: [rest | acc]

  def convert_polymer([first, second | rest], commands_map, acc) do
    val = Map.get(commands_map, {first, second})

    convert_polymer([second | rest], commands_map, [val, first | acc])
  end

  def count_chars(list) do
    Enum.reduce(list, %{}, fn char, acc ->
      val = Map.get(acc, char, 0)
      Map.put(acc, char, val + 1)
    end)
  end

  def solve1 do
    {start, commands_map} = read_file()

    result_counts =
      1..10
      |> Enum.reduce(start, fn _, acc ->
        convert_polymer(acc, commands_map, [])
        |> Enum.reverse()
      end)
      |> count_chars()
      |> Map.to_list()
      |> IO.inspect()
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.sort(:asc)

    [lowest | rest] = result_counts

    [highest | _] = Enum.reverse(rest)

    IO.inspect({lowest, highest})
    highest - lowest
  end

  def test_count(0, acc), do: IO.inspect(acc)

  def test_count(i, acc) do
    test_count(i - 1, acc + acc - 1)
  end

  def split_chain([], acc), do: Enum.reverse(acc)
  def split_chain([_rest], acc), do: Enum.reverse(acc)

  def split_chain([first, second | rest], acc) do
    split_chain([second | rest], [{first, second} | acc])
  end

  def count_pairs(pair_chain) do
    Enum.reduce(pair_chain, %{}, fn pair, acc_map ->
      val = Map.get(acc_map, pair, 0)
      Map.put(acc_map, pair, val + 1)
    end)
  end

  def build_cache_for_pair(pair, commands_map, level) do
    chain =
      1..level
      |> Enum.reduce(pair, fn _, acc ->
        convert_polymer(acc, commands_map, [])
      end)

    chain |> split_chain([]) |> count_pairs
  end

  def build_cache_for_all(commands_map, level) do
    Map.to_list(commands_map)
    |> Enum.reduce(%{}, fn {{first, second}, _}, acc_map ->
      result = build_cache_for_pair([first, second], commands_map, level)
      Map.put(acc_map, {first, second}, result)
    end)
  end

  def solve2 do
    {start, commands_map} = read_file()

    cache_for_pairs = build_cache_for_all(commands_map, 10)
    start_counts = start |> split_chain([]) |> count_pairs()

    result_pair_count = 1..1
    |> Enum.reduce(start_counts, fn i, acc_counts ->
      IO.inspect(i)
      Map.to_list(acc_counts)
      |> Enum.reduce(%{}, fn {pair, factor}, acc_map_counts ->
        cached = Map.fetch!(cache_for_pairs, pair)

        Map.to_list(cached)
        |> Enum.map(fn {pair, val} -> {pair, val * factor} end)
        |> Enum.reduce(acc_map_counts, fn {pair, val}, next_acc_map ->
          cur_val = Map.get(next_acc_map, pair, 0)
          Map.put(next_acc_map, pair, cur_val + val)
        end)
      end)
    end)

    # pair_count_list = result_pair_count |> Map.to_list
    # [first_char]
    # |> Enum.reduce(%{}, fn {{_first, second}} ->  end)

    # quizas descontar init_count - 2
  end
end

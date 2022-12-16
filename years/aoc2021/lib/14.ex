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

  def count_chars(list, base_map \\ %{}) do
    Enum.reduce(list, base_map, fn char, acc ->
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
        |> Enum.reverse()
      end)

    base_letter_count_map =
      pair
      |> Enum.reduce(%{}, fn letter, acc ->
        val = Map.get(acc, letter, 0)
        Map.put(acc, letter, val - 1)
      end)

    letter_count = count_chars(chain, base_letter_count_map)

    pair_count = chain |> split_chain([]) |> count_pairs

    {pair_count, letter_count}
  end

  def build_cache_for_all(commands_map, level) do
    Map.to_list(commands_map)
    |> Enum.reduce(%{}, fn {{first, second}, _}, acc_map ->
      result = build_cache_for_pair([first, second], commands_map, level)
      Map.put(acc_map, {first, second}, result)
    end)
  end

  def count_char_in_pairs(char, pair_count_map) do
    list = Map.to_list(pair_count_map)

    first_count =
      Enum.filter(list, fn {{ch, _}, _val} -> ch == char end)
      |> Enum.map(fn {_pair, value} -> value end)
      |> Enum.sum()

    second_count =
      Enum.filter(list, fn {{_, ch}, _val} -> ch == char end)
      |> Enum.map(fn {_pair, value} -> value end)
      |> Enum.sum()

    {first_count, second_count}
  end

  def solve2 do
    {start, commands_map} = read_file()

    cache_for_pairs = build_cache_for_all(commands_map, 10)

    start_pair_counts =
      start
      |> split_chain([])
      |> count_pairs()
      |> IO.inspect()

    start_letter_counts =
      start
      |> count_chars()
      |> IO.inspect()

    # start_pair_counts
    # |> Map.to_list()
    # |> Enum.map(fn {pair, factor} ->
    #   cache = Map.fetch!(cache_for_pairs, pair)
    #   %{:pair => pair, :factor => factor, :cache => cache}
    # end)

    {_, result_letter_count} =
      1..4
      |> Enum.reduce(
        {start_pair_counts, start_letter_counts},
        fn i, {acc_pair_counts_for_step, acc_letter_counts_for_step} ->
          IO.inspect({acc_pair_counts_for_step, acc_letter_counts_for_step}, label: i)

          Map.to_list(acc_pair_counts_for_step)
          |> Enum.reduce(
            {%{}, acc_letter_counts_for_step},
            fn {pair, factor}, {acc_pair_counts_for_pair, acc_letter_counts_for_pair} ->
              {pair_count, letter_count} = Map.fetch!(cache_for_pairs, pair)

              new_letter_count =
                Map.to_list(letter_count)
                |> Enum.map(fn {letter, val} -> {letter, val * factor} end)
                |> Enum.reduce(acc_letter_counts_for_pair, fn {letter, val}, next_acc_map ->
                  cur_val = Map.get(next_acc_map, letter, 0)
                  Map.put(next_acc_map, letter, cur_val + val)
                end)

              new_pair_count =
                Map.to_list(pair_count)
                |> Enum.map(fn {pair, val} -> {pair, val * factor} end)
                |> Enum.reduce(acc_pair_counts_for_pair, fn {pair, val}, next_acc_map ->
                  cur_val = Map.get(next_acc_map, pair, 0)
                  Map.put(next_acc_map, pair, cur_val + val)
                end)

              {new_pair_count, new_letter_count}
            end
          )
        end
      )

    result_letter_count |> Map.to_list() |> Enum.sort(fn {_, va}, {_, vb} -> va <= vb end)

    # pair_count_list = result_pair_count |> Map.to_list
    # [first_char]
    # |> Enum.reduce(%{}, fn {{_first, second}} ->  end)

    # quizas descontar init_count - 2
  end

  def solve1_print do
    {start, commands_map} = read_file()

    result_chain =
      1..20
      |> Enum.reduce(start, fn _, acc ->
        convert_polymer(acc, commands_map, [])
        |> Enum.reverse()
      end)

    %{
      :length => length(result_chain),
      :char_counts =>
        count_chars(result_chain)
        |> Map.to_list()
        |> Enum.sort(fn {_, va}, {_, vb} -> va <= vb end)
      # :pair_counts => result_chain |> split_chain([]) |> count_pairs
    }
  end
end

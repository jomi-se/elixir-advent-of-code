defmodule NumDecoder do
  #   0:      1:      2:      3:      4:
  #  aaaa    ....    aaaa    aaaa    ....
  # b    c  .    c  .    c  .    c  b    c
  # b    c  .    c  .    c  .    c  b    c
  #  ....    ....    dddd    dddd    dddd
  # e    f  .    f  e    .  .    f  .    f
  # e    f  .    f  e    .  .    f  .    f
  #  gggg    ....    gggg    gggg    ....

  #   5:      6:      7:      8:      9:
  #  aaaa    aaaa    aaaa    aaaa    aaaa
  # b    .  b    .  .    c  b    c  b    c
  # b    .  b    .  .    c  b    c  b    c
  #  dddd    dddd    ....    dddd    dddd
  # .    f  e    f  .    f  e    f  .    f
  # .    f  e    f  .    f  e    f  .    f
  #  gggg    gggg    ....    gggg    gggg
  #
  @nums %{
    0 => "abcefg",
    1 => "cf",
    2 => "acdeg",
    3 => "acdfg",
    4 => "bcdf",
    5 => "abdfg",
    6 => "abdefg",
    7 => "acf",
    8 => "abcdefg",
    9 => "abcdfg"
  }

  def read_file!() do
    {:ok, contents} = File.read("./years/aoc2021/input/8.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn str ->
      [numbers, output_numbers] =
        String.split(str, "|", trim: true)
        |> Enum.map(fn nums ->
          nums
          |> String.split(" ", trim: true)
          |> Enum.map(fn str_num ->
            String.graphemes(str_num)
            |> Enum.sort()
          end)
        end)

      {numbers, output_numbers}
    end)
  end

  def get_numbers_by_length(numbers) do
    numbers
    |> Enum.reduce(%{}, fn char_list, acc ->
      len = length(char_list)
      Map.put(acc, len, [char_list | Map.get(acc, len, [])])
    end)
  end

  def get_unique_numbers(numbers_by_length) do
    [one] = numbers_by_length |> Map.fetch!(2)
    [seven] = numbers_by_length |> Map.fetch!(3)
    [four] = numbers_by_length |> Map.fetch!(4)
    [eight] = numbers_by_length |> Map.fetch!(7)

    %{:one => one, :seven => seven, :four => four, :eight => eight}
  end

  def count_unique_numbers(output_numbers, unique_numbers) do
    %{:one => one, :seven => seven, :four => four, :eight => eight} = unique_numbers

    nums_set = MapSet.new([one, seven, four, eight] |> Enum.map(&Enum.join(&1, "")))

    output_numbers
    |> Enum.filter(fn num_list ->
      MapSet.member?(nums_set, Enum.join(num_list, ""))
    end)
    |> length()
  end

  def solve1() do
    read_file!()
    |> Enum.map(fn {numbers, output_numbers} ->
      unique_numbers =
        numbers
        |> get_numbers_by_length()
        |> get_unique_numbers()

      count_unique_numbers(output_numbers, unique_numbers)
    end)
    |> Enum.sum()
  end

  def find_missing_numbers(numbers_by_length, unique_numbers) do
    # if len == 2 then is number 1
    # if len == 3 then is number 7
    # if len == 4 then is number 4
    # if len == 7 then is number 8

    # if len == 5 & contains signals from 1 then number is 3
    # can now figure out which is 'a'
    # if len == 6 and not contains 4 then number is 0
    # if len == 6 and contains 3 then number is 9
    # if len == 6  then number is 6
    # if len == 5 and fits in 6 then number is 5
    # the other 5 is 2
    nums_len_5 = Map.fetch!(numbers_by_length, 5)
    nums_len_6 = Map.fetch!(numbers_by_length, 6)

    # OK
    three =
      Enum.find(nums_len_5, nil, fn num ->
        MapSet.subset?(MapSet.new(unique_numbers.one), MapSet.new(num))
      end)

    six =
      Enum.find(nums_len_6, nil, fn num ->
        !MapSet.subset?(MapSet.new(unique_numbers.seven), MapSet.new(num))
      end)

    nine =
      Enum.find(nums_len_6, nil, fn num ->
        MapSet.subset?(MapSet.new(three), MapSet.new(num))
      end)

    zero =
      Enum.find(nums_len_6, nil, fn num ->
        num !== six and num != nine
      end)

    five =
      Enum.find(nums_len_5, nil, fn num ->
        IO.inspect({num, six})
        MapSet.subset?(MapSet.new(num), MapSet.new(six))
      end)

    two =
      Enum.find(nums_len_5, nil, fn num ->
        num != five and num != three
      end)

    %{
      Enum.join(zero, "") => 0,
      Enum.join(unique_numbers.one, "") => 1,
      Enum.join(two, "") => 2,
      Enum.join(three, "") => 3,
      Enum.join(unique_numbers.four, "") => 4,
      Enum.join(five, "") => 5,
      Enum.join(six, "") => 6,
      Enum.join(unique_numbers.seven, "") => 7,
      Enum.join(unique_numbers.eight, "") => 8,
      Enum.join(nine, "") => 9
    }
  end

  def translate_number(output_numbers, decoded_numbers) do
    output_numbers
    |> Enum.map(fn str_num_list ->
      Map.fetch!(decoded_numbers, Enum.join(str_num_list, ""))
    end)
    |> Enum.join("")
    |> String.to_integer()
  end

  def solve2() do
    read_file!()
    |> Enum.map(fn {numbers, output_numbers} ->
      IO.puts("NEW LINE\n")
      numbers_by_length =
        numbers
        |> get_numbers_by_length()
      unique_numbers = get_unique_numbers(numbers_by_length)

      decoded_numbers = find_missing_numbers(numbers_by_length, unique_numbers)

      translate_number(output_numbers, decoded_numbers)
    end)
    |> Enum.sum()
  end

  def print_stuff() do
    _by_length =
      @nums
      |> Map.to_list()
      |> Enum.reduce(%{}, fn {number, chars}, acc ->
        len = String.length(chars)
        Map.put(acc, len, [{number, chars} | Map.get(acc, len, [])])
      end)
  end
end

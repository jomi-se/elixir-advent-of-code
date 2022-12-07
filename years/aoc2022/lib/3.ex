defmodule Rucksacks do
  def read_file() do
    {:ok, contents} = File.read("input/3.txt")

    String.split(contents, "\n", trim: true)
  end

  def checkRep(_charSet, []), do: {false, ""}

  def checkRep(charSet, [char | rest]) do
    cond do
      MapSet.member?(charSet, char) -> {true, char}
      true -> checkRep(charSet, rest)
    end
  end

  def findRepeated({first, second}) do
    strSet = MapSet.new(String.graphemes(first))
    {true, char} = checkRep(strSet, String.graphemes(second))

    char
  end

  def str_to_ascii(str) do
    [first] = str |> to_charlist()
    first
  end

  def getValue(char, "a"), do: str_to_ascii(char) - str_to_ascii("a") + 1
  def getValue(char, "A"), do: str_to_ascii(char) - str_to_ascii("A") + 27

  def translateVal(char) do
    cond do
      char == String.downcase(char) -> getValue(char, "a")
      true -> getValue(char, "A")
    end
  end

  def solve1() do
    read_file()
    |> Enum.map(fn string ->
      strLeng = div(String.length(string), 2)
      {String.slice(string, 0, strLeng), String.slice(string, strLeng, strLeng)}
    end)
    |> Enum.map(fn {first, second} ->
      findRepeated({first, second})
      |> translateVal()
    end)
    |> Enum.sum()
  end

  def findCommonLetterValue(group) do
    [first, second, third] = group
    |> Enum.map(&MapSet.new(String.graphemes(&1)))

    [badgeChar]=MapSet.intersection(first, second)
    |>MapSet.intersection(third)
    |> MapSet.to_list()

    translateVal(badgeChar)
  end

  def solve2() do
    read_file()
    |>Enum.chunk_every(3)
    |>Enum.map(&findCommonLetterValue(&1))
    |>Enum.sum()
  end
end

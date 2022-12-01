defmodule RationCalories do
  def read_file do
    calories_per_elf_raw =
      File.read!("./input/1.txt")
      |> String.split("\n\n", trim: true)

    Enum.map(calories_per_elf_raw, fn calories_raw ->
      parse_one(calories_raw)
    end)
  end

  def parse_one(text) do
    String.trim(text)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def find_max(list, acc)
  def find_max([], acc), do: acc

  def find_max([first | rest], acc) do
    sum = get_sum(first)

    find_max(rest, max(acc, sum))
  end

  def get_sum(list) do
    Enum.sum(list)
  end

  def sort_sums(list) do
    list
    |> Enum.map(&Enum.sum(&1))
    |> Enum.sort(&(&1 >= &2))
    end

  def solve1() do
    read_file()
    |> find_max(0)
  end

  def solve2() do
   [first, second, third | _]= read_file()
   |> sort_sums()

   Enum.sum([first, second, third])
  end
end

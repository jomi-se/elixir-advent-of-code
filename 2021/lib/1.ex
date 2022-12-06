defmodule DepthExplorer do
  def read_file() do
    {:ok, contents} = File.read("input/1.txt")

    String.trim(contents)
    |> String.split("\n")
    |> Enum.map(&String.to_integer(&1))
  end

  def do_count(list, acc)
  def do_count([_last], acc), do: acc

  def do_count([first, second | rest], acc) when first < second do
    do_count([second | rest], acc + 1)
  end

  def do_count([_first, second | rest], acc) do
    do_count([second | rest], acc)
  end

  def count_increases(list) do
    do_count(list, 0)
  end

  def solve() do
    read_file()
    |> count_increases()
  end

  def do_count2(list, acc)
  def do_count2([_, _, _], acc), do: acc

  def do_count2([first, second, third, fourth | rest], acc) do
    a = first + second + third
    b = second + third + fourth
    cond do
       a < b ->
        do_count2([second, third, fourth | rest], acc + 1)

      true ->
        do_count2([second, third, fourth | rest], acc)
    end
  end

  def count_increases2(list) do
    do_count2(list, 0)
  end

  def solve2() do
    read_file()
    |> count_increases2()
  end
end

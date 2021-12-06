defmodule LanternFish do
  def read_file() do
    File.read!("./input/6.txt")
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def do_tick(list, acc)
  def do_tick([], acc), do: acc
  def do_tick([0 | rest], acc), do: do_tick(rest, [8, 6 | acc])
  def do_tick([n | rest], acc), do: do_tick(rest, [n - 1 | acc])

  def solve() do
    initial_list = read_file()

    Enum.reduce(1..80, initial_list, fn _, list -> do_tick(list, []) end)
    |> length()
  end

  def add_n(map, num, n) do
    cur_count = Map.get(map, num, 0)
    Map.put(map, num, cur_count + n)
  end

  def into_map(list) do
    Enum.reduce(list, %{}, fn num, acc ->
      add_n(acc, num, 1)
    end)
  end

  def do_tick_map(map) do
    Enum.reduce(map, %{}, fn {num, count}, acc ->
      case num do
        0 -> acc |> add_n(6, count) |> add_n(8, count)
        _ -> add_n(acc, num - 1, count)
      end
    end)
  end

  def solve2(n) do
    initial_map =
      read_file()
      |> into_map()

    Enum.reduce(
      1..n,
      initial_map,
      fn _, map ->
        do_tick_map(map)
      end
    )
    |> Enum.reduce(0, fn {_, count}, acc -> acc + count end)
  end
end

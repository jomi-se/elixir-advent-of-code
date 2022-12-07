defmodule CrabGameBIG do
  def read_file do
    File.read!("./input/23.txt")
    |> String.trim("\n")
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def get_dest(1, p1, p2, p3), do: get_dest((1_000_001), p1, p2, p3)

  def get_dest(current, p1, p2, p3) do
    next = current - 1

    cond do
      p1 == next -> get_dest(next, p1, p2, p3)
      p2 == next -> get_dest(next, p1, p2, p3)
      p3 == next -> get_dest(next, p1, p2, p3)
      true -> next
    end
  end

  def get_picked_and_next(map, first) do
    %{ ^first => p1 } = map
    %{^p1 => p2} = map
    %{^p2 => p3} = map
    %{^p3 => next} = map
    {p1, p2, p3, next}
  end

  def play_round(map, _current_cup, count, max) when count == max, do: map
  def play_round(map, current_cup, count, max) do
    # if rem(count, 1000) == 0, do: IO.inspect(count)

    {p1, p2, p3, next} = get_picked_and_next(map, current_cup)
    dest = get_dest(current_cup, p1, p2, p3)

    # print(map, current_cup)
    # IO.inspect([p1, p2, p3])
    # IO.inspect(dest)

    cond do
      dest == current_cup ->
        play_round(map, p1, count + 1, max)

      true ->
        %{^dest => dest_target} = map

        new_map =
          %{map | current_cup => next, dest => p1, p3 => dest_target}

        play_round(new_map, next, count + 1, max)
    end
  end

  def do_print_seq(_map, start, cur, next, acc) when start == next, do: [cur|acc] |> Enum.reverse()
  def do_print_seq(map, start, cur, next, acc) do
    do_print_seq(map, start, next, map[next], [cur|acc])
  end

  def print(map, start), do: do_print_seq(map, start, start, map[start], []) |> IO.inspect()

  def part_2 do
    nums = read_file()

    [first | _] = nums

    {last, map} =
      (nums ++ Enum.to_list(10..(1_000_000)))
      |> Enum.reduce({first, %{}}, fn num, {prev, map} ->
        {num, Map.put(map, prev, num)}
      end)

    full_map = Map.put(map, last, first)

    result = play_round(full_map, first, 0, 10_000_000)

    first = result[1]
    second = result[first]
    IO.inspect({first, second})
    first * second
  end
end

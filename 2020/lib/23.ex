defmodule CrabGame do
  def read_file do
    File.read!("./input/23.txt")
    |> String.trim("\n")
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def get_dest(1, p1, p2, p3), do: get_dest(10, p1, p2, p3)

  def get_dest(current, p1, p2, p3) do
    next = current - 1

    cond do
      p1 == next -> get_dest(next, p1, p2, p3)
      p2 == next -> get_dest(next, p1, p2, p3)
      p3 == next -> get_dest(next, p1, p2, p3)
      true -> next
    end
  end

  def play_round(result, count, max) when count == max,  do: result
  def play_round([current_cup, p1, p2, p3 | rest], count, max) do
    dest = get_dest(current_cup, p1, p2, p3)

    IO.inspect([current_cup, p1, p2, p3 | rest])
    IO.inspect([p1, p2, p3])
    IO.inspect(dest)

    cond do
      dest == current_cup ->
        play_round([p1, p2, p3 | rest ] ++ [current_cup], count + 1, max)
      true ->
        dest_index = Enum.find_index(rest, &(dest == &1))
        prev = Enum.take(rest, dest_index + 1)
        post = Enum.take(rest, (dest_index + 1) - 5)
        play_round(prev ++ [p1, p2, p3] ++ post ++ [current_cup], count + 1, max)
    end
  end

  def part_1 do
   result = read_file()
   |> play_round(0, 1000)

   dest_index = Enum.find_index(result, &(1 == &1))
   prev = Enum.take(result, dest_index)
   post = Enum.take(result, (dest_index + 1) - 9)
   Enum.join(post ++ prev, "")

  end
end

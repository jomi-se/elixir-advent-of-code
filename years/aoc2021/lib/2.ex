defmodule SubmarineMovement do
  def read_file() do
    {:ok, contents} = File.read("input/2.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn string ->
      [word, number_raw] = String.split(string, " ")
      number = number_raw |> String.to_integer()
      {word, number}
    end)
  end

  def do_move(moves, current_coords)
  def do_move([], {hor_pos, depth}), do: {hor_pos, depth}

  def do_move([{"forward", value} | rest], {hor_pos, depth}),
    do: do_move(rest, {hor_pos + value, depth})

  def do_move([{"up", value} | rest], {hor_pos, depth}),
    do: do_move(rest, {hor_pos, depth - value})

  def do_move([{"down", value} | rest], {hor_pos, depth}),
    do: do_move(rest, {hor_pos, depth + value})

  def solve() do
    read_file()
    |> IO.inspect()
    |> do_move({0, 0})
  end

  def do_move2(moves, current_coords)
  def do_move2([], {hor_pos, aim, depth}), do: {hor_pos, aim, depth}

  def do_move2([{"forward", value} | rest], {hor_pos, aim, depth}),
    do: do_move2(rest, {hor_pos + value, aim, depth + (value * aim)})

  def do_move2([{"up", value} | rest], {hor_pos, aim, depth}),
    do: do_move2(rest, {hor_pos, aim - value, depth})

  def do_move2([{"down", value} | rest], {hor_pos, aim, depth}),
    do: do_move2(rest, {hor_pos, aim + value, depth})

  def solve2() do
    read_file()
    |> do_move2({0, 0, 0})
  end
end

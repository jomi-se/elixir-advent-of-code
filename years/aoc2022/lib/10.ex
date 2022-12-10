defmodule CathodeRayTube do
  def read_file() do
    File.read!("./years/aoc2022/input/10.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      str_list = String.split(line, " ", trim: true)
      [first] = Enum.take(str_list, 1)

      case first do
        "noop" ->
          {"noop", nil}

        "addx" ->
          [_, val] = str_list
          {"addx", String.to_integer(val)}
      end
    end)
  end

  def get_next_result(_reg, cycle, acc_result) when cycle < 20, do: acc_result

  def get_next_result(reg, cycle, acc_result) when rem(cycle - 20, 40) == 0,
    do: acc_result + reg * cycle

  def get_next_result(_reg, _cycle, acc_result), do: acc_result

  def read_command([], _wait, _acc_reg, _acc_cycle, acc_result), do: acc_result

  def read_command([{command, val} | rest], wait, acc_reg, acc_cycle, acc_result) do
    new_acc_result = get_next_result(acc_reg, acc_cycle, acc_result)
    # IO.inspect({{command, val}, wait, acc_reg, acc_cycle, acc_result, new_acc_result})
    new_wait = wait - 1

    case command do
      "noop" ->
        read_command(rest, new_wait, acc_reg, acc_cycle + 1, new_acc_result)

      "addx" when new_wait == 0 ->
        read_command(rest, new_wait, acc_reg + val, acc_cycle + 1, new_acc_result)

      "addx" ->
        read_command([{command, val} | rest], 1, acc_reg, acc_cycle + 1, new_acc_result)
    end
  end

  def solve1 do
    read_file()
    |> read_command(0, 1, 1, 0)
  end

  def get_next_pixel(reg, cycle, acc_line) do
    sprite_pos = rem(reg, 40)

    sprite_valid_vals =
      [-1, 0, 1]
      |> Enum.map(fn v -> sprite_pos + v end)
      |> Enum.filter(fn v -> v >= 0 and v <= 39 end)

    cond do
      rem(cycle - 1, 40) in sprite_valid_vals ->
        ["#" | acc_line]

      true ->
        ["." | acc_line]
    end
  end

  def read_command2([], _wait, _acc_reg, _acc_cycle, _acc_result), do: nil

  def read_command2([{command, val} | rest], wait, acc_reg, acc_cycle, acc_line) do
    tmp_acc_line = get_next_pixel(acc_reg, acc_cycle, acc_line)

    new_acc_line =
      cond do
        length(tmp_acc_line) == 40 ->
          IO.inspect(tmp_acc_line |> Enum.reverse() |> Enum.join(""))
          []

        true ->
          tmp_acc_line
      end

    # IO.inspect({{command, val}, wait, acc_reg, acc_cycle, acc_result, new_acc_result})
    new_wait = wait - 1

    case command do
      "noop" ->
        read_command2(rest, new_wait, acc_reg, acc_cycle + 1, new_acc_line)

      "addx" when new_wait == 0 ->
        read_command2(rest, new_wait, acc_reg + val, acc_cycle + 1, new_acc_line)

      "addx" ->
        read_command2([{command, val} | rest], 1, acc_reg, acc_cycle + 1, new_acc_line)
    end
  end

  def solve2 do
    read_file()
    |> read_command2(0, 1, 1, [])
  end
end

defmodule CodeChecker do
  def read_file() do
    {:ok, contents} = File.read("input/8.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {string, index}, acc ->
      [instruction, value] = String.split(string, " ")
      Map.put(acc, index, {instruction, String.to_integer(value)})
    end)
  end

  def do_operation(instruction, acc, cur_pos, instruction_map, has_switched)
  def do_operation({"nop", _}, acc, cur_pos, instruction_map, true),
    do: next_operation(acc, cur_pos + 1, instruction_map, true)
  def do_operation({"nop", value}, acc, cur_pos, instruction_map, false) do
    case next_operation(acc, cur_pos + 1, instruction_map, false) do
      :error -> do_operation({"jmp", value}, acc, cur_pos, instruction_map, true)
      val -> val
    end
  end

  def do_operation({"acc", value }, acc, cur_pos, instruction_map, has_switched),
    do: next_operation(acc + value, cur_pos + 1, instruction_map, has_switched)

  def do_operation({"jmp", value}, acc, cur_pos, instruction_map, true),
    do: next_operation(acc, cur_pos + value, instruction_map, true)
  def do_operation({"jmp", value}, acc, cur_pos, instruction_map, false) do
    case next_operation(acc, cur_pos + value, instruction_map, false) do
      :error -> do_operation({"nop", value}, acc, cur_pos, instruction_map, true)
      val -> val
    end
  end

  def next_operation(acc, target_pos, instruction_map, has_switched) do
    next = Map.get(instruction_map, target_pos)

    case next do
      nil -> acc
      {_, _, :visited} ->
        :error

      {instruction, value} ->
        do_operation(
          next,
          acc,
          target_pos,
          Map.put(instruction_map, target_pos, {instruction, value, :visited}),
          has_switched
        )
    end
  end

  def get_acc_auto_fix() do
    instruction_map = read_file()
    next_operation(0, 0, instruction_map, false)
  end
end

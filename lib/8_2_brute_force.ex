defmodule CodeCheckerBruteForce do
  def read_file() do
    {:ok, contents} = File.read("input/8.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {string, index}, acc ->
      [instruction, value] = String.split(string, " ")
      Map.put(acc, index, {instruction, String.to_integer(value)})
    end)
  end

  def do_operation(operation, acc, cur_pos, instruction_map)
  # def do_operation({_,_, :visited }, acc, _, _), do: acc
  def do_operation({"nop", _}, acc, cur_pos, instruction_map),
    do: next_operation(acc, cur_pos + 1, instruction_map)
  def do_operation({"acc", value }, acc, cur_pos, instruction_map),
    do: next_operation(acc + value, cur_pos + 1, instruction_map)
  def do_operation({"jmp", value}, acc, cur_pos, instruction_map),
    do: next_operation(acc, cur_pos + value, instruction_map)

  def next_operation(acc, target_pos, instruction_map) do
    next = Map.get(instruction_map, target_pos)

    case next do
        nil -> acc
      {_, _, :visited} ->
        false

      {instruction, value} ->
        do_operation(
          next,
          acc,
          target_pos,
          Map.put(instruction_map, target_pos, {instruction, value, :visited})
        )
    end
  end

  def get_cycleless_acc() do
    instruction_map = read_file()
    Map.keys(instruction_map)
    |> Enum.find_value(fn index ->
      case Map.get(instruction_map, index) do
        {"nop", value} -> next_operation(0, 0, Map.put(instruction_map, index, {"jmp", value}))
        {"jmp", value} -> next_operation(0, 0, Map.put(instruction_map, index, {"nop", value}))
        _ -> false
      end
    end)
  end
end

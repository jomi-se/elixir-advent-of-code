defmodule Memory do
  def get_input do
    {[13,16,0,12,15], 1}
  end

  def init_map(input) do
    indexed = Enum.with_index(input)
    for {v, index} <- indexed, into: %{}, do: {v, index}
  end

  def part_1 do
    {init_nums, next_num} = get_input()
    memory_map = init_map(init_nums)

    check_next_num(next_num, map_size(memory_map), memory_map)
  end

  def check_next_num(next_num, 29999999, _), do: next_num
  def check_next_num(next_num, cur_index, memory_map) do
    case Map.get(memory_map, next_num) do
      nil ->
        updated_map = Map.put(memory_map, next_num, cur_index)
        check_next_num(0, cur_index + 1, updated_map)

      index ->
        diff = cur_index - index
        updated_map = Map.put(memory_map, next_num, cur_index)
        check_next_num(diff, cur_index + 1, updated_map)
    end
  end
end

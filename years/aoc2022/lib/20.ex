defmodule CoordsDecrypt do
  def read_file() do
    {:ok, contents} = File.read("years/aoc2022/input/20.txt")

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def get_next_pos(num, cur_pos, list_size) when num > 0 and cur_pos + num >= list_size,
    do: rem(cur_pos + num, list_size - 1)

  def get_next_pos(num, cur_pos, list_size) when num > 0, do: rem(cur_pos + num, list_size)

  # def get_next_pos(num, cur_pos, list_size) when num < 0 and num - 1 + list_size < 0,
  #   do: get_next_pos(num - 1 + list_size, cur_pos, list_size)

  # def get_next_pos(num, cur_pos, list_size) when num < 0 and cur_pos + num < 0,
  #   do: rem(cur_pos + (num - 1) + list_size, list_size)

  def get_next_pos(num, cur_pos, list_size) when num < 0 do
    val = rem(cur_pos + num, list_size - 1)
    if val < 0, do: val + list_size - 1, else: val
  end

  def move_entry({0, _entry_orig_pos}, reordered_list, _list_size),
    do:
      reordered_list
      # |> IO.inspect(label: "no move")

  def move_entry({entry_num, entry_orig_pos}, reordered_list, list_size) do
    cur_pos =
      Enum.find_index(reordered_list, fn {num, pos} ->
        if pos == entry_orig_pos do
          if num != entry_num do
            raise "should not happen #{{num, entry_num}}"
          end

          true
        else
          false
        end
      end)

    new_pos = get_next_pos(entry_num, cur_pos, list_size)

    # IO.inspect({entry_num, cur_pos, new_pos}, label: "move comp")

    {head_list, [{num, orig_pos} | rest_list]} =
      Enum.split_while(reordered_list, fn {_, pos} -> entry_orig_pos !== pos end)

    case new_pos do
      0 ->
        [{num, orig_pos} | head_list] ++ rest_list

      n when n == list_size - 1 ->
        head_list ++ rest_list ++ [{num, orig_pos}]

      n ->
        head_len = length(head_list)

        cond do
          head_len == n ->
            head_list ++ [{num, orig_pos} | rest_list]

          head_len > n ->
            {f, r} = Enum.split(head_list, n)
            f ++ [{num, orig_pos} | r] ++ rest_list

          head_len < n ->
            {f, r} = Enum.split(rest_list, n - head_len)
            head_list ++ f ++ [{num, orig_pos} | r]
        end
    end
    # |> IO.inspect(label: "moved")
  end

  def move_nums_once([], acc, _list_size), do: acc

  def move_nums_once([{num, pos} | rest], acc, list_size) do
    move_nums_once(rest, move_entry({num, pos}, acc, list_size), list_size)
  end

  def solve1 do
    nums = read_file()

    nums_with_indexes =
      nums
      |> Enum.with_index()

    list_size = length(nums)

    res = move_nums_once(nums_with_indexes, nums_with_indexes, list_size)

    zero_idx = Enum.find_index(res, fn {v, _} -> v == 0 end)

    [1000, 2000, 3000]
    |> Enum.map(&Enum.at(res, rem(zero_idx + &1, list_size)))
    |> Enum.map(fn {n, _} -> n end)
    |> Enum.sum()
  end
end

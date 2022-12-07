defmodule Encryption do
  def read_file!() do
    {:ok, contents} = File.read("input/9.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {string, index}, acc ->
      Map.put(acc, index, String.to_integer(string))
    end)
  end

  def check_good_number?(num_map_by_index, cur_pos, window_size) do
    window_range = (cur_pos - window_size)..(cur_pos - 1)
    num_set = for i <- window_range, into: MapSet.new(), do: Map.get(num_map_by_index, i)
    cur_num = Map.get(num_map_by_index, cur_pos)

    window_range
    |> Enum.any?(fn i ->
      num = Map.get(num_map_by_index, i)
      num != cur_num - num && MapSet.member?(num_set, cur_num - num)
    end)
  end

  def get_wrong_number(num_map_by_index, window_size) do
    window_size..map_size(num_map_by_index)
    |> Enum.find_value(fn cur_pos ->
      case check_good_number?(num_map_by_index, cur_pos, window_size) do
        false -> Map.get(num_map_by_index, cur_pos)
        true -> false
      end
    end)
  end

  def part_1 do
    num_map_by_index = read_file!()
    get_wrong_number(num_map_by_index, 25)
  end

  def part_2 do
    num_map_by_index = read_file!()
    wrong_num = get_wrong_number(num_map_by_index, 25)

    1..map_size(num_map_by_index)
    |> Enum.find_value(fn cur_pos ->
      end_index =
        cur_pos..map_size(num_map_by_index)
        |> Enum.reduce_while(0, fn i, acc ->
          cur_num = Map.get(num_map_by_index, i)

        case cur_num + acc do
            sum when sum == wrong_num -> {:halt, i}
            sum when sum > wrong_num or i == map_size(num_map_by_index) - 1 -> {:halt, nil}
            sum -> {:cont, sum}
          end
        end)

      case end_index do
        n when not is_integer(n) ->
          false

        n ->
          {min, max} =
            cur_pos..n
            |> Enum.reduce(
              {Map.get(num_map_by_index, cur_pos), Map.get(num_map_by_index, cur_pos)},
              fn i, {cur_min, cur_max} ->
                cur_num = Map.get(num_map_by_index, i)
                {min(cur_min, cur_num), max(cur_max, cur_num)}
              end
            )

          min + max
      end
    end)
  end
end

defmodule Bitmasks_2 do
  import Bitwise

  def get_bitmasks_stream() do
    File.stream!("./input/14.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.chunk_by(&String.starts_with?(&1, "mask"))
    |> Stream.chunk_every(2)
    |> Stream.map(fn [mask_list, values] ->
      [mask_str] = mask_list
      mask = String.slice(mask_str, 7, 36)
      {mask, values}
    end)
  end

  def get_two_addreses_for_bit( bitwise_val,original_address ) do
    case band(original_address, bitwise_val) do
      0 -> [bor(original_address, bitwise_val), band(original_address, ~~~bitwise_val)]
      ^bitwise_val -> [bor(original_address, bitwise_val), bxor(original_address, bitwise_val)]
    end
  end

  #  xx1xx -> 00100 OR
  #  xxXxx -> 00100 XOR , 00100 OR

  def get_mask_operations(mask) do
    mask
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {val, _} -> val != "0" end)
    |> Enum.map(fn {val, index} ->
      case val do
        "1" -> {round(:math.pow(2, 35 - index)), &[bor(&1, &2)]}
        "X" -> {round(:math.pow(2, 35 - index)), &get_two_addreses_for_bit/2}
      end
    end)
  end

  def parse_memset(memset_line) do
    parsed = Regex.named_captures(~r/^mem\[(?<mempos>[0-9]+)\] = (?<value>[0-9]+)$/, memset_line)

    %{
      :mempos => [String.to_integer(parsed["mempos"])],
      :memval => String.to_integer(parsed["value"])
    }
  end

  def compute_bitwise_ops({mask, memset_ops_strs}, map) do
    mask_ops = get_mask_operations(mask)
    memset_ops = Enum.map(memset_ops_strs, &parse_memset/1)

    memset_ops
    |> Enum.map(fn memset ->
      addresses =
        Enum.reduce(mask_ops, memset.mempos, fn {maskval, bitfunc}, addresses_acc ->
          addresses_acc
          |> Enum.flat_map(&bitfunc.(maskval, &1))
        end)

      %{memset | :mempos => addresses}
    end)
    |> Enum.reduce(map, fn memset, map_acc ->
      memset.mempos
      |> Enum.reduce(map_acc, fn address, acc -> Map.put(acc, address, memset.memval) end)
    end)
  end

  def part_2() do
    get_bitmasks_stream()
    |> Enum.reduce(
      %{},
      fn stream_chunk, map_acc -> compute_bitwise_ops(stream_chunk, map_acc) end
    )
    |> Map.values()
    |> Enum.sum()
  end
end

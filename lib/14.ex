defmodule Bitmasks do
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

  #  xx0xx -> 11011 AND
  #  xx1xx -> 00100 OR
  def get_mask_operations(mask) do
    mask
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {val, _} -> val != "X" end)
    |> Enum.map(fn {val, index} ->
      case val do
        "1" -> {round(:math.pow(2, 35 - index)), &bor/2}
        "0" -> {~~~round(:math.pow(2, 35 - index)), &band/2}
      end
    end)
  end

  def parse_memset(memset_line) do
    parsed = Regex.named_captures(~r/^mem\[(?<mempos>[0-9]+)\] = (?<value>[0-9]+)$/, memset_line)

    %{
      :mempos => String.to_integer(parsed["mempos"]),
      :memval => String.to_integer(parsed["value"])
    }
  end

  def compute_bitwise_ops({mask, memset_ops_strs}, map) do
    mask_ops = get_mask_operations(mask)
    memset_ops = Enum.map(memset_ops_strs, &parse_memset/1)

    memset_ops
    |> Enum.map(fn memset ->
      new_val =
        Enum.reduce(mask_ops, memset.memval, fn {maskval, bitfunc}, acc ->
          bitfunc.(maskval, acc)
        end)

      %{memset | :memval => new_val}
    end)
    |> Enum.reduce(map, fn memset, map_acc ->
      Map.put(map_acc, memset.mempos, memset.memval)
    end)
  end

  def part_1() do
    get_bitmasks_stream()
    |> Enum.reduce(
      %{},
      fn stream_chunk, map_acc -> compute_bitwise_ops(stream_chunk, map_acc) end
    )
    |> Map.values()
    |> Enum.sum()
  end
end

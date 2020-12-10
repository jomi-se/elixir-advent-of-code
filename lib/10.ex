defmodule Jolts do
  def read_file!() do
    {:ok, contents} = File.read("input/10.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(&String.to_integer(&1))
    |> Enum.sort()
  end

  def part_1 do
    {_, result} =
      read_file!()
      |> Enum.reduce({0, %{1 => 0, 2 => 0, 3 => 1}}, fn adapter, {cur_jolt, map} ->
        diff = adapter - cur_jolt
        {adapter, Map.update!(map, diff, &(&1 + 1))}
      end)

    result[1] * result[3]
  end

  def part_2 do
    {last, _, acc} =
      read_file!()
      |> Enum.reduce({[0], 0, []}, fn adapter, {cur_chain, prev, acc} ->
        cond do
          adapter - prev == 1 -> {[adapter | cur_chain], adapter, acc}
          true -> {[adapter], adapter, [cur_chain | acc]}
        end
      end)

    Enum.reduce([last | acc], 1, fn list, acc ->
      multiplier =
        case length(list) do
          1 -> 1
          2 -> 1
          3 -> 2
          4 -> 4
          5 -> 7
          6 -> 11
        end

      acc * multiplier
    end)
  end
end

defmodule PassportScanner do
  def get_passport_stream() do
    File.stream!("./input/4.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(&do_parse(&1, %{}))
  end

  def do_parse([], map), do: map

  def do_parse([string | tail], map) do
    new_map =
      string
      |> String.split(" ")
      |> Enum.reduce(map, fn str_chunk, acc ->
        [key, val] = String.split(str_chunk, ":")
        Map.put(acc, key, val)
      end)

    do_parse(tail, new_map)
  end

  def count_valid() do
    get_passport_stream()
    |> Enum.count(fn passport ->
      cond do
        map_size(passport) == 8 -> true
        map_size(passport) == 7 && !Map.has_key?(passport, "cid") -> true
        true -> false
      end
    end)
  end
end

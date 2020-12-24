defmodule Hexagon do
  def read_file do
    File.read!("./input/24.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(string) do
    chars = String.graphemes(string)
    do_parse(chars, [])
  end

  def do_parse([], acc), do: acc |> Enum.reverse()
  def do_parse([e = "e" | rest], acc), do: do_parse(rest, [e | acc])
  def do_parse([w = "w" | rest], acc), do: do_parse(rest, [w | acc])
  def do_parse([ns, ew | rest], acc), do: do_parse(rest, [ns <> ew | acc])

  @directions ["e", "se", "sw", "w", "nw", "ne"]
  def next_coords({x, y, z}, "e"), do: {x + 1, y + 1, z}
  def next_coords({x, y, z}, "se"), do: {x + 1, y, z - 1}
  def next_coords({x, y, z}, "sw"), do: {x, y - 1, z - 1}
  def next_coords({x, y, z}, "w"), do: {x - 1, y - 1, z}
  def next_coords({x, y, z}, "nw"), do: {x - 1, y, z + 1}
  def next_coords({x, y, z}, "ne"), do: {x, y + 1, z + 1}

  def travel_hex(pos, []), do: pos
  def travel_hex(pos, [move | moves]), do: travel_hex(next_coords(pos, move), moves)

  def part_1 do
    read_file()
    |> Enum.map(fn moves_list -> travel_hex({0, 0, 0}, moves_list) end)
    |> Enum.reduce(%{}, fn coords, map ->
      Map.update(map, coords, :black, fn existing ->
        case existing do
          :black -> :white
          :white -> :black
        end
      end)
    end)
    |> Map.to_list()
    |> Enum.count(fn {_coords, colour} -> colour == :black end)
  end

  def part_2 do
    black_tiles =
      read_file()
      |> Enum.map(fn moves_list -> travel_hex({0, 0, 0}, moves_list) end)
      |> Enum.reduce(%{}, fn coords, map ->
        Map.update(map, coords, :black, fn existing ->
          case existing do
            :black -> :white
            :white -> :black
          end
        end)
      end)
      |> Map.to_list()
      |> Enum.filter(fn {_coords, colour} -> colour == :black end)
      |> Enum.map(fn {coords, _} -> coords end)

      tick(black_tiles, 0, 100)
      |> length
  end

  def tick(black_tiles, count, max) when count == max, do: black_tiles

  def tick(black_tiles, count, max) do
    black_tiles_set = MapSet.new(black_tiles)

    {white_adj_counts, next_black_tiles} =
      Enum.reduce(black_tiles, {%{}, []}, fn coords, {adj_counts, rem_blacks} ->
        adj_coords = @directions |> Enum.map(&next_coords(coords, &1))

        {new_adj_counts, black_adj_count} =
          Enum.reduce(adj_coords, {adj_counts, 0}, fn adj_coord, {adj_counts_acc, count_black} ->
            case MapSet.member?(black_tiles_set, adj_coord) do
              true ->
                {adj_counts_acc, count_black + 1}

              false ->
                {Map.update(adj_counts_acc, adj_coord, 1, &(1 + &1)),count_black }
            end
          end)

        cond do
          black_adj_count == 0 or black_adj_count > 2 ->
            {new_adj_counts, rem_blacks}

          true ->
            {new_adj_counts, [coords| rem_blacks]}
        end
      end)

    white_to_black = white_adj_counts
    |> Map.to_list()
    |> Enum.filter(fn {_coord, count} -> count == 2 end)
    |> Enum.map(fn {coord, _} -> coord end)

    white_to_black_set = MapSet.new(white_to_black)
    if (not MapSet.disjoint?(black_tiles_set, white_to_black_set)), do: raise "AAAAAAAHHAHAHA"

    tick(next_black_tiles ++ white_to_black, count + 1, max)
  end
end

defmodule SyntaxErrorScores do
  def read_file!() do
    File.read!("./years/aoc2021/input/10.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes(&1))
  end

  def get_closed("("), do: ")"
  def get_closed("["), do: "]"
  def get_closed("{"), do: "}"
  def get_closed("<"), do: ">"

  def get_score(")"), do: 3
  def get_score("]"), do: 57
  def get_score("}"), do: 1197
  def get_score(">"), do: 25137

  def read_next_char([], _open_chars), do: 0
  def read_next_char([char | rest], []), do: read_next_char(rest, [char])

  def read_next_char([char | rest], [open_char | rest_open]) do
    case char do
      value when value in ["(", "[", "{", "<"] ->
        read_next_char(rest, [char, open_char | rest_open])

      _ ->
        case char == get_closed(open_char) do
          true -> read_next_char(rest, rest_open)
          _ -> get_score(char)
        end
    end
  end

  def solve1 do
    read_file!()
    |> Enum.map(fn char_list -> read_next_char(char_list, []) end)
    |> Enum.sum()
  end

  def get_score2(")"), do: 1
  def get_score2("]"), do: 2
  def get_score2("}"), do: 3
  def get_score2(">"), do: 4

  def compute_score([], score), do: score

  def compute_score([open_char | rest], score),
    do: compute_score(rest, score * 5 + get_score2(get_closed(open_char)))

  def read_next_char2([], open_chars) do
    compute_score(open_chars, 0)
  end
  def read_next_char2([char | rest], []), do: read_next_char2(rest, [char])

  def read_next_char2([char | rest], [open_char | rest_open]) do
    case char do
      value when value in ["(", "[", "{", "<"] ->
        read_next_char2(rest, [char, open_char | rest_open])

      _ ->
        case char == get_closed(open_char) do
          true -> read_next_char2(rest, rest_open)
          _ -> 0
        end
    end
  end

  def solve2 do
    scores =
      read_file!()
      |> Enum.map(fn char_list -> read_next_char2(char_list, []) end)
      |> Enum.filter(fn score -> score > 0 end)
      |> Enum.sort()
      |> Enum.with_index()
      |> Enum.map(fn {score, index} -> {index, score} end)
      |> Map.new()

    Map.get(scores, div(map_size(scores), 2))
  end
end

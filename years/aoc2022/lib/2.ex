defmodule RPS do
  def read_file() do
    {:ok, contents} = File.read("input/2.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn string ->
      [enemy, me] = String.split(string, " ")
      {enemy, me}
    end)
  end

  def str_to_ascii(str) do
    [first] = str |> to_charlist()
    first
  end

  def ascii_to_str(num), do: List.to_string([num])

  def get_winner(char) do
    base_a = str_to_ascii("A")
    ascii_char = str_to_ascii(char)

    winner_ascii = rem(ascii_char - base_a + 1, 3)
    ascii_to_str(winner_ascii + base_a)
  end

  def get_loser(char) do
    base_a = str_to_ascii("A")
    ascii_char = str_to_ascii(char)

    loser_ascii = rem(ascii_char - base_a - 1 + 3, 3)
    ascii_to_str(loser_ascii + base_a)
  end

  def translate(char)
  def translate("X"), do: "A"
  def translate("Y"), do: "B"
  def translate("Z"), do: "C"

  def translate2(char_pair)

  def translate2({enemy, outcome}) do
    case outcome do
      "X" -> get_loser(enemy)
      "Z" -> get_winner(enemy)
      _ -> enemy
    end
  end

  def move_score(char)
  def move_score("A"), do: 1
  def move_score("B"), do: 2
  def move_score("C"), do: 3

  def compute_match(pair)
  # draws
  def compute_match({enemy, me}) when enemy === me, do: 3
  # Wins / lose
  def compute_match({enemy, me}) do
    case get_winner(enemy) do
      ^me -> 6
      _ -> 0
    end
  end

  def solve1() do
    read_file()
    |> Enum.map(fn {enemy, me} ->
      move_score(translate(me)) + compute_match({enemy, translate(me)})
    end)
    |> Enum.sum()
  end

  def solve2() do
    read_file()
    |> Enum.map(fn {enemy, me} ->
      my_move = translate2({enemy, me})
      move_score(my_move) + compute_match({enemy, my_move})
    end)
    |> Enum.sum()
  end
end

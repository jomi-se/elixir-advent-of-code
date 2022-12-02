defmodule RPS do
  def read_file() do
    {:ok, contents} = File.read("input/2.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn string ->
      [enemy, me] = String.split(string, " ")
      {enemy, me}
    end)
  end

  def translate(char)
  def translate("X"), do: "A"
  def translate("Y"), do: "B"
  def translate("Z"), do: "C"

  def translate2(char_pair)
  def translate2({"A", "X"}), do: "C"
  def translate2({"A", "Y"}), do: "A"
  def translate2({"A", "Z"}), do: "B"

  def translate2({"B", "X"}), do: "A"
  def translate2({"B", "Y"}), do: "B"
  def translate2({"B", "Z"}), do: "C"

  def translate2({"C", "X"}), do: "B"
  def translate2({"C", "Y"}), do: "C"
  def translate2({"C", "Z"}), do: "A"

  def move_score(char)
  def move_score("A"), do: 1
  def move_score("B"), do: 2
  def move_score("C"), do: 3

  def compute_match(pair)
  # Wins
  def compute_match({"A", "B"}), do: 6
  def compute_match({"B", "C"}), do: 6
  def compute_match({"C", "A"}), do: 6
  # draws
  def compute_match({enemy, me}) when enemy === me, do: 3
  # lose
  def compute_match(_pair), do: 0

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

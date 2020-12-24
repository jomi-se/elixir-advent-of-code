defmodule CombatCards do
  def read_file do
    File.read!("./input/22.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn player_str ->
      [_| cards] = String.split(player_str, "\n", trim: true)
      Enum.map(cards, &String.to_integer(&1))
    end)
  end

  def play_round([], cards), do: cards
  def play_round(cards, []), do: cards

  def play_round([first1 | rest1], [first2 | rest2]) do
    cond do
      first1 > first2 ->
        play_round(rest1 ++ [first1, first2], rest2)

      first2 > first1 ->
        play_round(rest1, rest2 ++ [first2, first1])

      true ->
        raise "AY"
    end
  end

  def part_1 do
    [player1, player2] = read_file()

    play_round(player1, player2)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {val, index}, acc -> acc + val * (index + 1) end)
  end

  def check_game_round(player1, player2, memory) do
    Enum.any?(memory, fn {p1, p2} -> p1 == player1 and p2 == player2 end)
  end

  def check_should_play_subgame(player1, player2) do
    [first1 | rest1] = player1
    [first2 | rest2] = player2
    first1 <= length(rest1) and first2 <= length(rest2)
  end

  def play_sub_game(player1, player2) do
    [first1 | rest1] = player1
    [first2 | rest2] = player2

    sub_player1 = Enum.take(rest1, first1)
    sub_player2 = Enum.take(rest2, first2)
    play_game_round(sub_player1, sub_player2, [])
  end

  def play_game_round(player1, [], _memory), do: {:p1, player1}
  def play_game_round([], player2, _memory), do: {:p2, player2}
  def play_game_round(player1, player2, memory) do
    cond do
      check_game_round(player1, player2, memory) -> {:p1, []}
      check_should_play_subgame(player1, player2) ->
        new_memory = [{player1, player2}|memory]
        [first1 | rest1] = player1
        [first2 | rest2] = player2
        case play_sub_game(player1, player2) do
          {:p1, _} -> play_game_round(rest1 ++ [first1, first2], rest2, new_memory)
          {:p2, _} -> play_game_round(rest1, rest2 ++ [first2, first1], new_memory)
        end

        true ->
        new_memory = [{player1, player2}|memory]
        [first1 | rest1] = player1
        [first2 | rest2] = player2
        cond do
          first1 > first2 ->
            play_game_round(rest1 ++ [first1, first2], rest2, new_memory)

          first2 > first1 ->
            play_game_round(rest1, rest2 ++ [first2, first1], new_memory)
        end
    end
  end

  def part_2 do
    [player1, player2] = read_file()

    {_, winner_deck} = play_game_round(player1, player2, [])
    winner_deck
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {val, index}, acc -> acc + val * (index + 1) end)
  end
end

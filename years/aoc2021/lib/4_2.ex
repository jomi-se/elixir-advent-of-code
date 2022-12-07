defmodule SquidBingo2 do
  def read_file() do
    [numbers | boards] =
      File.read!("./input/4.txt")
      |> String.split("\n\n", trim: true)

    numbers_parsed =
      numbers
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer(&1))

    boards_parsed =
      boards
      |> Enum.reduce([], fn board, acc_out ->
        board_parsed =
          board
          |> String.split("\n", trim: true)
          |> Enum.with_index()
          |> Enum.reduce({%{}, %{}}, fn {strLine, y}, acc ->
            strLine
            |> String.split(~r/ +/, trim: true)
            |> Enum.with_index()
            |> Enum.reduce(acc, fn {num_str, x}, {acc_by_pos, acc_by_num} ->
              num = String.to_integer(num_str)

              {
                Map.put(acc_by_pos, {x, y}, {num, false}),
                Map.put(acc_by_num, num, {x, y})
              }
            end)
          end)

        [board_parsed | acc_out]
      end)

    {numbers_parsed, boards_parsed}
  end

  def get_size(board) do
    Kernel.map_size(board)
    |> :math.sqrt()
    |> floor()
  end

  def check_winner({:not_found, board_by_pos}), do: {:nope, board_by_pos}

  def check_winner({:found, board_by_pos}) do
    size = get_size(board_by_pos)

    result =
      board_by_pos
      |> Enum.reduce_while(%{}, fn {{x, y}, {_, marked}}, acc ->
        case marked do
          false ->
            {:cont, acc}

          true ->
            col_count = Map.get(acc, {x, :col}, 0) + 1
            row_count = Map.get(acc, {y, :row}, 0) + 1

            cond do
              col_count == size || row_count == size ->
                {:halt, :found}

              true ->
                new_map =
                  acc
                  |> Map.put({x, :col}, col_count)
                  |> Map.put({y, :row}, row_count)

                {:cont, new_map}
            end
        end
      end)

    case result do
      :found -> {:yas, board_by_pos}
      _ -> {:nope, board_by_pos}
    end
  end

  def mark_num_in_board({board_by_pos, board_by_num}, num) do
    result =
      case(Map.get(board_by_num, num)) do
        {x, y} -> {:found, Map.put(board_by_pos, {x, y}, {num, true})}
        nil -> {:not_found, board_by_pos}
      end

    check_winner(result)
  end

  def mark_nums(nums, boards)

  def mark_nums([num | rest], boards) do
    result =
      Enum.reduce(
        boards,
        [],
        fn {board_by_pos, board_by_num}, acc_boards ->
          {found, new_board_by_pos} = mark_num_in_board({board_by_pos, board_by_num}, num)

          case found do
            :yas ->
              acc_boards

            :nope ->
              [{new_board_by_pos, board_by_num} | acc_boards]
          end
        end
      )

    case result do
      [] -> {num, boards}
      _ -> mark_nums(rest, result)
    end
  end

  def count_score(winning_num, {board_by_pos, _}) do
    winning_num *
      Enum.reduce(board_by_pos, 0, fn {_, {num, marked}}, acc ->
        case marked do
          false ->
            acc + num

          true ->
            acc
        end
      end)
  end

  def solve() do
    {numbers_parsed, boards_parsed} = read_file()

    {winning_num, [{winning_board_by_pos, winning_board_by_num}]} =
      mark_nums(numbers_parsed, boards_parsed)

    # lazy to rewrite everything for the last case
    {_, marked_winning_board_by_pos} =
      mark_num_in_board({winning_board_by_pos, winning_board_by_num}, winning_num)

    count_score(winning_num, {marked_winning_board_by_pos, winning_board_by_num})
  end
end

defmodule DistressSignal do
  def read_file do
    File.read!("./years/aoc2022/input/13.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn str ->
      [left, right] =
        String.split(str, "\n", trim: true)
        |> Enum.map(fn line ->
          {list, _bindings} = Code.eval_string(line)
          list
        end)

      [left, right]
    end)
  end

  def compare_two([], []) do
    :eq
  end

  def compare_two([], [_ | _right_rest]) do
    :lt
  end

  def compare_two([_ | _left_rest], []) do
    :gt
  end

  def compare_two([left_int | left_rest], [right_int | right_rest])
      when is_integer(left_int) and is_integer(right_int) do
    cond do
      left_int < right_int -> :lt
      left_int == right_int -> compare_two(left_rest, right_rest)
      true -> :gt
    end
  end

  def compare_two([left_list | left_rest], [right_int | right_rest])
      when is_list(left_list) and
             is_integer(right_int) do
    compare_two([left_list | left_rest], [[right_int] | right_rest])
  end

  def compare_two([left_int | left_rest], [right_list | right_rest])
      when is_integer(left_int) and
             is_list(right_list) do
    compare_two([[left_int] | left_rest], [right_list | right_rest])
  end

  def compare_two([left_list | left_rest], [right_list | right_rest])
      when is_list(left_list) and is_list(right_list) do
    case compare_two(left_list, right_list) do
      :lt -> :lt
      :eq -> compare_two(left_rest, right_rest)
      :gt -> :gt
    end
  end

  def sorter(list_before, list_after) do
    case compare_two(list_before, list_after) do
      res when res in [:lt, :eq] -> true
      _ -> false
    end
  end

  def solve1 do
    read_file()
    |> Enum.with_index()
    |> Enum.map(fn {[left, right], index} ->
      IO.inspect(binding(), label: "before")

      {compare_two(left, right), index + 1}
      |> IO.inspect(label: "result")
    end)
    |> Enum.reduce(0, fn {is_right, index}, acc ->
      case is_right do
        :lt ->
          acc + index

        _ ->
          acc
      end
    end)
  end

  def solve2 do
    result =
      read_file()
      |> Enum.reduce([[[2]], [[6]]], fn [left, right], acc ->
        [left, right | acc]
      end)
      |> Enum.sort(&DistressSignal.sorter/2)
      |> Enum.with_index()
      |> IO.inspect(charlists: :as_lists)

    first =
      Enum.find_value(result, fn {value, index} ->
        case value do
          [[2]] -> index + 1
          _ -> false
        end
      end)

    second =
      Enum.find_value(result, fn {value, index} ->
        case value do
          [[6]] -> index + 1
          _ -> false
        end
      end)

    IO.inspect({first, second})

    first * second
  end
end

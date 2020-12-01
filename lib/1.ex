defmodule ExpenseReport do
  def read_file() do
    {:ok, contents} = File.read("input/1.txt")

    String.split(contents, "\n")
    |> Enum.map(&String.to_integer(&1))
  end

  def find_pair(numbers) do
    Enum.reduce_while(numbers, %{}, fn num, acc ->
     check_num(num, acc)
    end)
  end

  def check_num(num, acc)
  def check_num(num, acc) when num >= 2020, do: acc

  def check_num(num, targets) do
    cond do
      Map.has_key?(targets, num) ->
        {:halt, (2020 - num) * num}

      Map.has_key?(targets, 2020 - num) ->
        {:halt, (2020 - num) * num}

      true ->
        {:cont, Map.put(targets, 2020 - num, :ok)}
    end
  end

  def solve() do
    read_file()
    |> find_pair()
  end

  def find_pair2(numbers) do
    numbers
    |> Enum.map(fn str_num ->
      2020 - str_num
    end)
    |> Enum.find_value(:error, fn target ->
      res =
        Enum.reduce_while(numbers, %{}, fn num, acc ->
          check_num2(num, target, acc)
        end)

      case res do
        x when is_number(x) -> x
        _ -> false
      end
    end)
  end

  def check_num2(num, target, acc)
  def check_num2(num, target, acc) when num >= target, do: {:cont, acc}

  def check_num2(num, target, targets) do
    cond do
      Map.has_key?(targets, num) ->
        {:halt, (target - num) * num * (2020 - target)}

      Map.has_key?(targets, target - num) ->
        {:halt, (target - num) * num * (2020 - target)}

      true ->
        {:cont, Map.put(targets, target - num, :ok)}
    end
  end

  def solve2() do
    read_file()
    |> find_pair2()
  end
end

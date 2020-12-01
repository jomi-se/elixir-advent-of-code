defmodule ExpenseReport do
  def read_file() do
    {:ok, contents} = File.read("input/1.txt")
    String.split(contents, "\n")
  end

  def find_pair(str_numbers) do
      Enum.reduce_while(str_numbers, %{}, fn num_str, acc ->
        num_str
        |> String.to_integer()
        |> check_num(acc)
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
end

defmodule PathPass do
  def read_file() do
    [map, instructions] =
      File.read!("./years/aoc2022/input/22.txt")
      |> String.split("\n\n", trim: true)

    parsed_map =
      map
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {v, y} -> {v, y + 1} end)
      |> Enum.reduce(
        %{
          :max_y => 1,
          :min_y => 1,
          :max_x => 1,
          :min_x => 1
        },
        fn {values, y}, map ->
          values
          |> String.trim("\n")
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn {v, x} -> {v, x + 1} end)
          |> Enum.reduce(map, fn {pos_value, x}, acc ->
            case pos_value do
              " " ->
                acc

              _ ->
                Map.put(acc, {x, y}, pos_value)
                |> Map.put(:max_y, max(acc.max_y, y))
                |> Map.put(:max_x, max(acc.max_x, x))
            end
          end)
        end
      )

    parsed_instructions =
      instructions
      |> String.trim("\n")
      |> String.graphemes()
      |> parse_instructions([])

    {parsed_map, parsed_instructions}
  end

  def get_char([char | rest]) when char in ["R", "L"], do: {char, [char|rest]}

  def get_num(char_list, acc \\ [])

  def get_num([num | rest], acc) when num in ["R", "L"],
    do: {acc |> Enum.reverse() |> Enum.join("") |> String.to_integer(), [num|rest]}

  def get_num([num | rest], acc), do: get_num(rest, [num | acc])

  def parse_instructions([], acc), do: acc |> Enum.reverse()

  def parse_instructions(char_list, acc) do
    IO.inspect(binding())
    {num, rest_chars} = get_num(char_list)
    |> IO.inspect()

    case rest_chars do
      [] ->
        [num | acc] |> Enum.reverse()

      _ ->
        {char, rest_chars2} = get_char(rest_chars)
        parse_instructions(rest_chars2, [char, num | acc])
    end
  end

  def solve1 do
    read_file()
  end
end

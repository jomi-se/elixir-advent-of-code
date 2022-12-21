defmodule MonkeyNums do
  def read_file() do
    File.read!("./years/aoc2022/input/21.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn pair ->
      [name, rest] =
        pair
        |> String.split(": ", trim: true)

      cond do
        Regex.match?(~r/^\d+$/, rest) ->
          {name, %{:num => String.to_integer(rest)}}

        true ->
          %{"left" => left, "op" => op, "right" => right} =
            Regex.named_captures(
              ~r/^(?<left>[a-zA-Z]+) (?<op>[\+\-\/\*]) (?<right>[a-zA-Z]+)$/,
              rest
            )

          fun =
            case op do
              "+" ->
                fn l, r -> l + r end

              "-" ->
                fn l, r -> l - r end

              "*" ->
                fn l, r -> l * r end

              "/" ->
                fn l, r -> div(l, r) end
            end

          {name, %{:left => left, :right => right, :fun => fun}}
      end
    end)
    |> Map.new()
  end

  def get_monkey_val(name, map) do
    monkey = Map.fetch!(map, name)

    case Map.get(monkey, :num, nil) do
      nil ->
        {left_num, new_map_left} = get_monkey_val(monkey.left, map)
        {right_num, new_map_right} = get_monkey_val(monkey.right, new_map_left)
        num = monkey.fun.(left_num, right_num)
        new_monkey = Map.put(monkey, :num, num)
        {num, Map.put(new_map_right, name, new_monkey)}

      num ->
        {num, map}
    end
  end

  def solve1 do
    monkey_map = read_file()

    {root_num, _new_monkey_map} = get_monkey_val("root", monkey_map)
    root_num
  end
end

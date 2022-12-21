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
          {name, %{:num => String.to_integer(rest), :name => name, :has_humn => name == "humn"}}

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

          {name, %{:left => left, :right => right, :fun => fun, :op => op, :name => name}}
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

  def has_humn(name, map) do
    monkey = Map.fetch!(map, name)

    case Map.get(monkey, :num, nil) do
      nil ->
        {has_left, left_map} = has_humn(monkey.left, map)
        {has_right, right_map} = has_humn(monkey.right, left_map)

        has = has_left or has_right
        new_monkey = Map.put(monkey, :has_humn, has)
        {has, Map.put(right_map, name, new_monkey)}

      _ ->
        {monkey.has_humn, map}
    end
  end

  def solve1 do
    monkey_map = read_file()

    {root_num, _new_monkey_map} = get_monkey_val("root", monkey_map)
    root_num
  end

  def compute_new_base_num(base_num, other_num, "+", _), do: base_num - other_num
  def compute_new_base_num(base_num, other_num, "*", _), do: div(base_num, other_num)
  def compute_new_base_num(base_num, other_num, "-", :right), do: base_num + other_num
  def compute_new_base_num(base_num, other_num, "-", :left), do: other_num - base_num
  def compute_new_base_num(base_num, other_num, "/", :right), do: base_num * other_num
  def compute_new_base_num(base_num, other_num, "/", :left), do: div(other_num, base_num)

  def compute_humn_value(base_num, "humn", _monkey_map), do: base_num

  def compute_humn_value(base_num, name, monkey_map) do
    monkey = Map.fetch!(monkey_map, name)

    left_monkey = Map.fetch!(monkey_map, monkey.left)
    right_monkey = Map.fetch!(monkey_map, monkey.right)

    cond do
      left_monkey.has_humn ->
        {base_right, new_monkey_map} = get_monkey_val(right_monkey.name, monkey_map)
        new_base_num = compute_new_base_num(base_num, base_right, monkey.op, :right)
        compute_humn_value(new_base_num, left_monkey.name, new_monkey_map)

      right_monkey.has_humn ->
        {base_left, new_monkey_map} = get_monkey_val(left_monkey.name, monkey_map)
        new_base_num = compute_new_base_num(base_num, base_left, monkey.op, :left)
        compute_humn_value(new_base_num, right_monkey.name, new_monkey_map)
    end
  end

  def solve2 do
    monkey_map = read_file()

    root_monkey = Map.fetch!(monkey_map, "root")
    {has_left, left_map} = has_humn(root_monkey.left, monkey_map)
    {has_right, right_map} = has_humn(root_monkey.right, left_map)
    IO.inspect({has_left, has_right})

    {monkey_to_compute, monkey_with_humn} =
      cond do
        has_left ->
          {root_monkey.right, root_monkey.left}

        has_right ->
          {root_monkey.left, root_monkey.right}
      end

    {base_num, new_monkey_map} = get_monkey_val(monkey_to_compute, right_map)

    compute_humn_value(base_num, monkey_with_humn, new_monkey_map)
  end
end

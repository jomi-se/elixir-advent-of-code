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
      |> String.split(~r/(\d+)/, include_captures: true, trim: true)
      |> Enum.map(fn
        char when char in ["L", "R"] -> char
        num -> String.to_integer(num)
      end)

    {parsed_map, parsed_instructions}
  end

  def get_next_dir("N", "R"), do: "E"
  def get_next_dir("E", "R"), do: "S"
  def get_next_dir("S", "R"), do: "W"
  def get_next_dir("W", "R"), do: "N"

  def get_next_dir("E", "L"), do: "N"
  def get_next_dir("S", "L"), do: "E"
  def get_next_dir("W", "L"), do: "S"
  def get_next_dir("N", "L"), do: "W"

  def step_coords("N"), do: {0, -1}
  def step_coords("S"), do: {0, 1}
  def step_coords("E"), do: {1, 0}
  def step_coords("W"), do: {-1, 0}

  def wrap_around(pos, cur_dir, map)
  def wrap_around({x, y}, "E", map) when x > map.max_x, do: wrap_around({map.min_x, y}, "E", map)

  def wrap_around({x, y}, "E", map) do
    case Map.get(map, {x, y}, nil) do
      nil ->
        wrap_around({x + 1, y}, "E", map)

      "#" ->
        nil

      "." ->
        {x, y}
    end
  end

  def wrap_around({x, y}, "W", map) when x < map.min_x, do: wrap_around({map.max_x, y}, "W", map)

  def wrap_around({x, y}, "W", map) do
    case Map.get(map, {x, y}, nil) do
      nil ->
        wrap_around({x - 1, y}, "W", map)

      "#" ->
        nil

      "." ->
        {x, y}
    end
  end

  def wrap_around({x, y}, "S", map) when y > map.max_y, do: wrap_around({x, map.min_y}, "S", map)

  def wrap_around({x, y}, "S", map) do
    case Map.get(map, {x, y}, nil) do
      nil ->
        wrap_around({x, y + 1}, "S", map)

      "#" ->
        nil

      "." ->
        {x, y}
    end
  end

  def wrap_around({x, y}, "N", map) when y < map.min_y, do: wrap_around({x, map.max_y}, "N", map)

  def wrap_around({x, y}, "N", map) do
    case Map.get(map, {x, y}, nil) do
      nil ->
        wrap_around({x, y - 1}, "N", map)

      "#" ->
        nil

      "." ->
        {x, y}
    end
  end

  def get_next_pos({x, y}, _cur_dir, 0, _map), do: {x, y}

  def get_next_pos({x, y}, cur_dir, steps, map) do
    {x1, y1} = step_coords(cur_dir)

    {x2, y2} = {x + x1, y + y1}

    case Map.get(map, {x2, y2}, nil) do
      nil ->
        # wrap around
        case wrap_around({x2, y2}, cur_dir, map) do
          nil ->
            # blocked
            {x, y}

          new_pos ->
            get_next_pos(new_pos, cur_dir, steps - 1, map)
        end

      "#" ->
        # blocked
        {x, y}

      "." ->
        # take step
        get_next_pos({x2, y2}, cur_dir, steps - 1, map)
    end
  end

  def do_move(pos, cur_dir, instructions, map)

  def do_move(pos, cur_dir, [], _map),
    do: {pos, cur_dir}

  def do_move({x, y}, cur_dir, ["R" | rest], map),
    do: do_move({x, y}, get_next_dir(cur_dir, "R"), rest, map)

  def do_move({x, y}, cur_dir, ["L" | rest], map),
    do: do_move({x, y}, get_next_dir(cur_dir, "L"), rest, map)

  def do_move({x, y}, cur_dir, [instr | rest], map) when is_integer(instr) do
    do_move(get_next_pos({x, y}, cur_dir, instr, map), cur_dir, rest, map)
  end

  def get_dir_value("E"), do: 0
  def get_dir_value("S"), do: 1
  def get_dir_value("W"), do: 2
  def get_dir_value("N"), do: 3

  def solve1 do
    {parsed_map, parsed_instructions} = read_file()

    start_pos = wrap_around({1, 1}, "E", parsed_map)

    {{x, y}, last_dir} =
      do_move(start_pos, "E", parsed_instructions, parsed_map)
      |> IO.inspect()

    y * 1000 + x * 4 + get_dir_value(last_dir)
  end


  ##
  def wrap_around_2({x,y}, "E", map) when x == 150 and y <= 50 and y >= 1 do
    new_pos = {100, 151 - y}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "W"}
    end
  end
  def wrap_around_2({x,y}, "E", map) when x == 100 and y <= 150 and y >= 101 do
    new_pos = {150, 151 - y}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "W"}
    end
  end
  ##

  ##
  def wrap_around_2({x,y}, "N", map) when x <= 150  and x >= 101 and y == 1 do
    new_pos = {x-100, 200}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      ->  {new_pos, "N"}
    end
  end
  def wrap_around_2({x,y}, "S", map) when x <= 50  and x >= 1 and y == 200 do
    new_pos = {x+100, 1}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "S"}
    end
  end
  ##

  ##
  def wrap_around_2({x,y}, "N", map) when x <= 100  and x >= 51 and y == 1 do
    new_pos = {1, 100+x}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "E"}
    end
  end
  def wrap_around_2({x,y}, "W", map) when x == 1  and y >= 151 and y <= 200 do
    new_pos = {y-100, 1}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "S"}
    end
  end
  ##

  ##
  def wrap_around_2({x,y}, "W", map) when x == 51 and y >= 1 and y <= 50 do
    new_pos = {1, 151 - y}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "E"}
    end
  end
  def wrap_around_2({x,y}, "W", map) when x == 1 and y >= 101 and y <= 150 do
    new_pos = {51, 151-y}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "E"}
    end
  end
  ##

  ##
  def wrap_around_2({x,y}, "W", map) when x == 51 and y >= 51 and y <= 100 do
    new_pos = {y-50, 101}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "S"}
    end
  end
  def wrap_around_2({x,y}, "N", map) when x >= 1 and x <= 50 and y == 101 do
    new_pos = {51, x+50}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "E"}
    end
  end
  ##

  ##
  def wrap_around_2({x,y}, "S", map) when x >= 101 and x <= 150 and y == 50 do
    new_pos = {100, x - 50}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "W"}
    end
  end
  def wrap_around_2({x,y}, "E", map) when x == 100 and y >= 51 and y <= 100 do
    new_pos = {50+y, 50}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "N"}
    end
  end
  ##

  ##
  def wrap_around_2({x,y}, "S", map) when x >= 51 and x <= 100 and y == 150 do
    new_pos = {50, x + 100}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "W"}
    end
  end
  def wrap_around_2({x,y}, "E", map) when x == 50 and y >= 151 and y <= 200 do
    new_pos = {y-100, 150}

    case Map.get(map, new_pos, nil) do
      "#" -> nil

      "."
      -> {new_pos, "N"}
    end
  end
  ##

  def get_next_pos2({x, y}, cur_dir, 0, _map), do: {{x, y}, cur_dir}

  def get_next_pos2({x, y}, cur_dir, steps, map) do
    {x1, y1} = step_coords(cur_dir)

    {x2, y2} = {x + x1, y + y1}

    case Map.get(map, {x2, y2}, nil) do
      nil ->
        # wrap around
        case wrap_around_2({x, y}, cur_dir, map) do
          nil ->
            # blocked
            {{x, y}, cur_dir}

          {new_pos, new_dir} ->
            get_next_pos2(new_pos, new_dir, steps - 1, map)
        end

      "#" ->
        # blocked
        {{x, y}, cur_dir}

      "." ->
        # take step
        get_next_pos2({x2, y2}, cur_dir, steps - 1, map)
    end
  end

  def do_move_2(pos, cur_dir, instructions, map)

  def do_move_2(pos, cur_dir, [], _map),
    do: {pos, cur_dir}

  def do_move_2({x, y}, cur_dir, ["R" | rest], map),
    do: do_move_2({x, y}, get_next_dir(cur_dir, "R"), rest, map)

  def do_move_2({x, y}, cur_dir, ["L" | rest], map),
    do: do_move_2({x, y}, get_next_dir(cur_dir, "L"), rest, map)

  def do_move_2({x, y}, cur_dir, [instr | rest], map) when is_integer(instr) do
    {next_pos,next_dir} = get_next_pos2({x, y}, cur_dir, instr, map)
    do_move_2(next_pos, next_dir, rest, map)
  end

  def solve2 do
    {parsed_map, parsed_instructions} = read_file()

    start_pos = wrap_around({1, 1}, "E", parsed_map)

    {{x, y}, last_dir} =
      do_move_2(start_pos, "E", parsed_instructions, parsed_map)
      |> IO.inspect()

    y * 1000 + x * 4 + get_dir_value(last_dir)
  end
end

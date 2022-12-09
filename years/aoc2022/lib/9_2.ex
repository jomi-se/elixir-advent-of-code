defmodule RopeBridge2 do
  def read_file() do
    File.read!("./years/aoc2022/input/9.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [direction, steps] = String.split(line, " ", trim: true)
      {direction, String.to_integer(steps)}
    end)
  end

  def direction("U"), do: {0, 1}
  def direction("D"), do: {0, -1}
  def direction("R"), do: {1, 0}
  def direction("L"), do: {-1, 0}

  def step_knots({_follow_x, _follow_y}, [], new_knots_reversed), do: new_knots_reversed

  def step_knots({follow_x, follow_y}, [{knot_x, knot_y} | rest_knots], new_knots_reversed) do
    dist_x = follow_x - knot_x
    dist_y = follow_y - knot_y

    {new_knot_x, new_knot_y} =
      cond do
        abs(dist_x) == 2 || abs(dist_y) == 2 ->
          # step T
          cond do
            dist_x == 0 or dist_y == 0 ->
              {knot_x + div(dist_x, 2), knot_y + div(dist_y, 2)}

            true ->
              {knot_x + div(dist_x, abs(dist_x)), knot_y + div(dist_y, abs(dist_y))}
          end

        abs(dist_x) > 2 || abs(dist_y) > 2 ->
          throw("problemas")

        true ->
          {knot_x, knot_y}
      end

    step_knots({new_knot_x, new_knot_y}, rest_knots, [
      {new_knot_x, new_knot_y} | new_knots_reversed
    ])
  end

  def move_steps({_, 0}, new_visited_positions, new_knots_pos, new_pos_h),
    do: {new_visited_positions, new_knots_pos, new_pos_h}

  def move_steps({dir, steps}, visited_positions, knots_pos, {h_x, h_y}) do
    {h_move_x, h_move_y} = direction(dir)
    {new_h_x, new_h_y} = {h_move_x + h_x, h_move_y + h_y}

    new_knots_reversed = step_knots({new_h_x, new_h_y}, knots_pos, [])
    [new_tail|_] = new_knots_reversed
    new_visited_positions = Map.put(visited_positions, new_tail, true)
    move_steps({dir, steps - 1}, new_visited_positions, Enum.reverse(new_knots_reversed), {new_h_x, new_h_y})
  end

  def get_next_step([], visited_positions, _pos_t, _pos_h), do: visited_positions

  def get_next_step([{dir, steps} | rest], visited_positions, knots_pos, {h_x, h_y}) do
    {new_visited_positions, new_knots, new_pos_h} =
      move_steps({dir, steps}, visited_positions, knots_pos, {h_x, h_y})

    get_next_step(rest, new_visited_positions, new_knots, new_pos_h)
  end

  def solve2 do
    read_file()
    |> get_next_step(%{{0, 0} => true}, List.duplicate({0, 0}, 9), {0, 0})
    |> map_size()
  end
end

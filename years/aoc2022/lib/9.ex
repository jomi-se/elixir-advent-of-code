defmodule RopeBridge do
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

  def move_steps({_, 0}, new_visited_positions, new_pos_t, new_pos_h),
    do: {new_visited_positions, new_pos_t, new_pos_h}

  def move_steps({dir, steps}, visited_positions, {t_x, t_y}, {h_x, h_y}) do
    {h_move_x, h_move_y} = direction(dir)
    {new_h_x, new_h_y} = {h_move_x + h_x, h_move_y + h_y}
    dist_x = new_h_x - t_x
    dist_y = new_h_y - t_y

    cond do
      abs(dist_x) == 2 || abs(dist_y) == 2 ->
        # step T
        new_pos_t =
          cond do
            dist_x == 0 or dist_y == 0 ->
              {t_x + div(dist_x, 2), t_y + div(dist_y, 2)}

            true ->
              {t_x + div(dist_x, abs(dist_x)), t_y + div(dist_y, abs(dist_y))}
          end

        new_visited_positions = Map.put(visited_positions, new_pos_t, true)
        move_steps({dir, steps - 1}, new_visited_positions, new_pos_t, {new_h_x, new_h_y})

      abs(dist_x) > 2 || abs(dist_y) > 2 ->
        throw("problemas")

      true ->
        move_steps({dir, steps - 1}, visited_positions, {t_x, t_y}, {new_h_x, new_h_y})
    end
  end

  def get_next_step([], visited_positions, _pos_t, _pos_h), do: visited_positions

  def get_next_step([{dir, steps} | rest], visited_positions, {t_x, t_y}, {h_x, h_y}) do
    {new_visited_positions, new_pos_t, new_pos_h} =
      move_steps({dir, steps}, visited_positions, {t_x, t_y}, {h_x, h_y})

    get_next_step(rest, new_visited_positions, new_pos_t, new_pos_h)
  end

  def solve1 do
    read_file()
    |> get_next_step(%{{0,0} => true}, {0, 0}, {0, 0})
    |> map_size()
  end
end

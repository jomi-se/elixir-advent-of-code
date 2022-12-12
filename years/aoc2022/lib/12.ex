defmodule HillCLimbing do
  def read_file do
    File.read!("./years/aoc2022/input/12.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {values, y}, map ->
      values
      |> String.trim("\n")
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {pos_value, x}, acc ->
        acc_map =
          Map.put(acc, {x, y}, pos_value)
          |> Map.put(:max_y, y)
          |> Map.put(:max_x, x)

        if pos_value == "S", do: Map.put(acc_map, :start_pos, {x, y}), else: acc_map
      end)
    end)
  end

  def check_if_done([], _grid), do: {:continue, nil}

  def check_if_done([{x, y} | pos_list_rest], grid) do
    case Map.fetch!(grid, {x, y}) do
      "E" -> {:done, {x, y}}
      _ -> check_if_done(pos_list_rest, grid)
    end
  end

  def to_integer_value("E"), do: 25
  def to_integer_value("S"), do: 0

  def to_integer_value(char) do
    [first] = char |> to_charlist()
    [val_a] = "a" |> to_charlist()

    first - val_a
  end

  def get_next_step_positions(positions, grid, visited_grid, acc_next_step_positions \\ [])

  def get_next_step_positions([], _grid, visited_grid, acc_next_step_positions),
    do: {acc_next_step_positions, visited_grid}

  def get_next_step_positions(
        [{x, y} | next_positions_rest],
        grid,
        visited_grid,
        acc_next_step_positions
      ) do
    cur_val = Map.fetch!(grid, {x, y}) |> to_integer_value()

    positions_to_maybe_add =
      [
        {1, 0},
        {-1, 0},
        {0, 1},
        {0, -1}
      ]
      |> Enum.map(fn {x1, y1} -> {x + x1, y + y1} end)
      |> Enum.filter(fn {x1, y1} ->
        next_val_char = Map.get(grid, {x1, y1})

        case next_val_char do
          nil -> false
          _ -> to_integer_value(next_val_char) - cur_val <= 1
        end
      end)

    {next_positions_list, new_visited_grid} =
      Enum.reduce(positions_to_maybe_add, {[], visited_grid}, fn {x1, y1},
                                                                 {acc_list, acc_visited_grid} ->
        cond do
          Map.has_key?(acc_visited_grid, {x1, y1}) ->
            {acc_list, acc_visited_grid}

          true ->
            {[{x1, y1} | acc_list], Map.put(acc_visited_grid, {x1, y1}, true)}
        end
      end)

    get_next_step_positions(
      next_positions_rest,
      grid,
      new_visited_grid,
      next_positions_list ++ acc_next_step_positions
    )
  end

  # With BFS without keeping track of the path we can figure out the distance
  # to destination without exploding the memory
  def bfs_search_step(grid, visited_grid, steps_queue, step_count) do
    {{:value, next_positions}, steps_queue_popped} = :queue.out(steps_queue)

    # Check if done
    case check_if_done(next_positions, grid) do
      {:done, _} ->
        {:done, step_count}

      {:continue, _} ->
        new_step_count = step_count + 1

        {next_step_positions, new_visited_grid} =
          get_next_step_positions(next_positions, grid, visited_grid)

        new_steps_queue = :queue.in(next_step_positions, steps_queue_popped)
        bfs_search_step(grid, new_visited_grid, new_steps_queue, new_step_count)
    end
  end

  def solve1 do
    grid = read_file()
    bfs_search_step(grid, %{grid.start_pos => true}, :queue.from_list([[grid.start_pos]]), 0)
  end

  def solve2 do
    grid = read_file()

    low_positions =
      grid |> Map.to_list() |> Enum.filter(fn {_, val} -> val == "a" or val == "S" end) |> Enum.map(fn {{x,y},_} -> {x,y} end)

    start_visited = low_positions |> Enum.map(fn {x, y} -> {{x, y}, true} end) |> Map.new()
    start_queue = :queue.from_list([low_positions])
    bfs_search_step(grid, start_visited, start_queue, 0)
  end
end

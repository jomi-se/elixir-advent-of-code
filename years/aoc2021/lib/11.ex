defmodule Octopus do
  def read_file do
    File.read!("./years/aoc2021/input/11.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {values, y}, map ->
      values
      |> String.trim("\n")
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {pos_value, x}, acc ->
        Map.put(acc, {x, y}, String.to_integer(pos_value))
        # |> Map.put(:max_y, y)
        # |> Map.put(:max_x, x)
      end)
    end)
  end

  def step_positions(positions_with_val) do
    Enum.reduce(positions_with_val, {%{}, %{}}, fn {{x, y}, val}, {acc_map, over_nines} ->
      new_val = val + 1

      if new_val > 9,
        do: {Map.put(acc_map, {x, y}, 0), Map.put(over_nines, {x, y}, true)},
        else: {Map.put(acc_map, {x, y}, new_val), over_nines}
    end)
  end

  def step_all_once(map) do
    map
    |> Map.to_list()
    |> step_positions()
  end

  def get_valid_neighbors({x, y}, map) do
    for x1 <- -1..1, y1 <- -1..1, not (x1 == 0 and y1 == 0) do
      {x + x1, y + y1}
    end
    |> Enum.filter(fn {x1, y1} ->
      val = Map.get(map, {x1, y1})
      val != nil and val != 0
    end)
  end

  def trigger_flashes(map, positions_to_trigger, triggered_positions)
      when positions_to_trigger == %{} do
    {map, triggered_positions}
  end

  def trigger_flashes(map, positions_to_trigger, triggered_positions) do
    {next_map, next_pos_to_trigger} =
      Map.to_list(positions_to_trigger)
      |> Enum.reduce({map, %{}}, fn {{x, y}, true}, {acc_map, acc_new_to_trigger} ->
        valid_neighbours =
          get_valid_neighbors({x, y}, acc_map)
          |> Enum.map(fn {x1, y1} -> {{x1, y1}, Map.fetch!(acc_map, {x1, y1})} end)

        {stepped_neighbours_map, neighbours_to_trigger} = step_positions(valid_neighbours)

        {Map.merge(acc_map, stepped_neighbours_map),
         Map.merge(acc_new_to_trigger, neighbours_to_trigger)}
      end)

    trigger_flashes(
      next_map,
      next_pos_to_trigger,
      Map.merge(triggered_positions, positions_to_trigger)
    )
  end

  def get_row({x, y}, map, acc) do
    case Map.get(map, {x, y}) do
      nil -> Enum.reverse(acc)
      value -> get_row({x + 1, y}, map, [value | acc])
    end
  end

  def get_rows(y, map, acc) do
    case get_row({0, y}, map, []) do
      [] -> Enum.reverse(acc)
      row -> get_rows(y + 1, map, [row | acc])
    end
  end

  def print_map(map) do
    get_rows(0, map, [])
    |> Enum.map_join("\n", fn row -> Enum.join(row, "") end)
    |> IO.puts()

    IO.puts("")

    map
  end

  def solve1 do
    start_map = read_file()

    1..100
    |> Enum.reduce({start_map, 0}, fn iter, {acc_map, iters_count} ->
      {stepped_map, pos_to_trigger} = step_all_once(acc_map)

      {next_map, triggered_positions} = trigger_flashes(stepped_map, pos_to_trigger, %{})

      if rem(iter, 10) == 0 do
        IO.puts("Step: #{iter}")
        IO.puts("triggered: #{iters_count + map_size(triggered_positions)}")
        print_map(next_map)
      end

      {next_map, iters_count + map_size(triggered_positions)}
    end)
  end

  def solve2 do
    start_map = read_file()

    1..1000
    |> Enum.reduce_while({start_map, 0}, fn iter, {acc_map, iters_count} ->
      {stepped_map, pos_to_trigger} = step_all_once(acc_map)

      {next_map, triggered_positions} = trigger_flashes(stepped_map, pos_to_trigger, %{})

      if rem(iter, 10) == 0 do
        IO.puts("Step: #{iter}")
        IO.puts("triggered: #{iters_count + map_size(triggered_positions)}")
        print_map(next_map)
      end

      cond do
        map_size(triggered_positions) == 100 -> {:halt, iter}
        true -> {:cont, {next_map, iters_count + map_size(triggered_positions)}}
      end
    end)
  end
end

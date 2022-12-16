defmodule ProboscideaVolcanium do
  def read_file() do
    File.read!("./years/aoc2022/input/16.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"valve" => valve, "rate" => rate_str, "dest_valves_str" => dest_valves_str} =
        Regex.named_captures(
          ~r/^Valve (?<valve>[A-Z]{2}) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<dest_valves_str>.+)$/,
          line
        )

      dest_valves = dest_valves_str |> String.split(", ")

      %{:valve => valve, :rate => String.to_integer(rate_str), :dest_valves => dest_valves}
    end)
  end

  def get_valves_with_rates_sorted(valves) do
    valves
    |> Enum.filter(fn valve -> valve.rate > 0 end)
    |> Enum.sort(fn va, vb -> va.rate >= vb.rate end)
  end

  def factorial(0), do: 1

  def factorial(i) when i > 0 do
    i * factorial(i - 1)
  end

  def check_if_done([], _dest), do: false
  def check_if_done([valve | _rest], dest) when valve.valve == dest, do: true
  def check_if_done([_valve | rest], dest), do: check_if_done(rest, dest)

  def get_next_step_positions(positions, graph, visited_positions, acc_next_step_positions \\ [])

  def get_next_step_positions([], _graph, visited_positions, acc_next_step_positions),
    do: {acc_next_step_positions, visited_positions}

  def get_next_step_positions(
        [valve | next_positions_rest],
        graph,
        visited_positions,
        acc_next_step_positions
      ) do
    positions_to_add =
      valve.dest_valves
      |> Enum.filter(fn valve_name -> valve_name not in visited_positions end)
      |> Enum.map(fn valve_name -> Map.fetch!(graph, valve_name) end)

    new_visited_grid = visited_positions |> MapSet.union(MapSet.new(positions_to_add))

    get_next_step_positions(
      next_positions_rest,
      graph,
      new_visited_grid,
      positions_to_add ++ acc_next_step_positions
    )
  end

  # With BFS without keeping track of the path we can figure out the distance
  # to destination without exploding the memory
  def bfs_search_step(graph, visited_positions, steps_queue, destination, step_count) do
    {{:value, next_positions}, steps_queue_popped} = :queue.out(steps_queue)

    # Check if done
    case check_if_done(next_positions, destination) do
      true ->
        step_count

      false ->
        new_step_count = step_count + 1

        {next_step_positions, new_visited_positions} =
          get_next_step_positions(next_positions, graph, visited_positions)

        new_steps_queue = :queue.in(next_step_positions, steps_queue_popped)

        bfs_search_step(
          graph,
          new_visited_positions,
          new_steps_queue,
          destination,
          new_step_count
        )
    end
  end

  def get_dist_between_valves(valve_start, valve_end, graph) do
    bfs_search_step(
      graph,
      MapSet.new([valve_start.valve]),
      :queue.from_list([[valve_start]]),
      valve_end.valve,
      0
    )
  end

  def pick_two_list(valves) do
    valves
    |> Enum.reduce(MapSet.new(), fn valve1, acc_out ->
      Enum.reduce(valves, acc_out, fn valve2, acc ->
        valve_tuple = [valve1.valve, valve2.valve] |> Enum.sort() |> List.to_tuple()

        cond do
          valve2.valve == valve1.valve ->
            acc

          valve_tuple in acc ->
            acc

          true ->
            MapSet.put(acc, valve_tuple)
        end
      end)
    end)
  end

  def next_valves_by_score_sorted(cur_valve, closed_valves, time_left, valve_distances) do
    next_valves =
      closed_valves
      |> Enum.reduce(%{}, fn valve, acc_map ->
        valve_tuple = [cur_valve.valve, valve.valve] |> Enum.sort() |> List.to_tuple()
        dist = Map.fetch!(valve_distances, valve_tuple)
        new_time_left = time_left - dist - 1
        score = new_time_left * valve.rate

        cond do
          score <= 0 ->
            acc_map

          true ->
            cur_score_valves = Map.get(acc_map, score, [])
            Map.put(acc_map, score, [{valve, new_time_left} | cur_score_valves])
        end
      end)
      |> Map.to_list()
      |> Enum.sort(fn {sa, _}, {sb, _} -> sa > sb end)

    next_valves
  end

  def next_valves_by_closest_sorted(cur_valve, closed_valves, time_left, valve_distances) do
    closest_valves =
      closed_valves
      |> Enum.reduce(%{}, fn valve, acc_map ->
        valve_tuple = [cur_valve.valve, valve.valve] |> Enum.sort() |> List.to_tuple()
        dist = Map.fetch!(valve_distances, valve_tuple)

        cur_dist_valves = Map.get(acc_map, dist, [])
        Map.put(acc_map, dist, [valve | cur_dist_valves])
      end)
      |> Map.to_list()
      |> Enum.sort(fn {da, _}, {db, _} -> da < db end)

    Enum.map(closest_valves, fn {dist, next_valves} ->
      next_valves
      |> Enum.map(fn valve ->
        new_time_left = time_left - dist - 1
        score = new_time_left * valve.rate

        {valve, score, new_time_left}
      end)
    end)
    |> List.flatten()
  end

  def solve_tsp_by_closest_neighbour(
        _cur_valve,
        [],
        _time_left,
        _valve_distances,
        cur_score,
        acc_scores
      ),
      do: [cur_score | acc_scores]

  def solve_tsp_by_closest_neighbour(
        _cur_valve,
        _closed_valves,
        time_left,
        _valve_distances,
        cur_score,
        acc_scores
      )
      when time_left <= 0,
      do: [cur_score | acc_scores]

  def solve_tsp_by_closest_neighbour(
        cur_valve,
        closed_valves,
        time_left,
        valve_distances,
        cur_score,
        acc_scores
      ) do

    next_valves =
      next_valves_by_closest_sorted(cur_valve, closed_valves, time_left, valve_distances)

    next_valves
    |> Enum.reduce(acc_scores, fn {next_valve, score, new_time_left}, acc ->
      next_closed_valves = closed_valves |> Enum.filter(&(&1.valve != next_valve.valve))

      solve_tsp_by_closest_neighbour(
        next_valve,
        next_closed_valves,
        new_time_left,
        valve_distances,
        cur_score + score,
        acc
      )
    end)
  end

  def solve1 do
    all_valves = read_file()

    res =
      all_valves
      |> get_valves_with_rates_sorted()

    graph =
      all_valves
      |> Enum.map(&{&1.valve, &1})
      |> Map.new()

    valve_tuples =
      pick_two_list([Map.fetch!(graph, "AA") | res])

    valve_distances_map =
      valve_tuples
      |> Enum.map(fn {valve_name1, valve_name2} ->
        valve1 = Map.fetch!(graph, valve_name1)
        valve2 = Map.fetch!(graph, valve_name2)

        {{valve_name1, valve_name2}, get_dist_between_valves(valve1, valve2, graph)}
      end)
      |> Map.new()

    solve_tsp_by_closest_neighbour(Map.fetch!(graph, "AA"), res, 30, valve_distances_map, 0, [])
    |> Enum.sort(:desc)
  end
end

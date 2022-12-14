defmodule PassagePathing do
  def read_file() do
    {:ok, contents} = File.read("./years/aoc2021/input/12.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.reduce(%{}, fn string, acc_map ->
      [first, second] = String.split(string, "-")

      dest_from_first = Map.get(acc_map, first, [])
      dest_from_second = Map.get(acc_map, second, [])

      Map.put(acc_map, first, [second | dest_from_first])
      |> Map.put(second, [first | dest_from_second])
    end)
  end

  def is_small_cave(cave), do: cave == String.downcase(cave)

  def get_next_caves(cur_cave, graph, visited_caves) do
    dest_caves = Map.fetch!(graph, cur_cave)

    Enum.reduce(dest_caves, [], fn dest_cave, acc ->
      cond do
        !is_small_cave(dest_cave) -> [dest_cave | acc]
        is_small_cave(dest_cave) and Map.get(visited_caves, dest_cave) == nil -> [dest_cave | acc]
        true -> acc
      end
    end)
  end

  def dsf_search_step(_graph, _visited_caves, [], paths_found), do: paths_found

  def dsf_search_step(graph, visited_caves, [cur_cave | rest], paths_found) do
    next_caves = get_next_caves(cur_cave, graph, visited_caves)

    Enum.reduce(next_caves, paths_found, fn next_cave, acc_paths_found ->
      cond do
        next_cave == "end" ->
          acc_paths_found + 1

        true ->
          dsf_search_step(
            graph,
            Map.put(visited_caves, cur_cave, true),
            [next_cave, cur_cave, rest],
            acc_paths_found
          )
      end
    end)
  end

  def solve1 do
    read_file()
    |> dsf_search_step(%{"start" => true}, ["start"], 0)
  end

  def get_next_caves2(cur_cave, graph, visited_caves, did_double) do
    dest_caves = Map.fetch!(graph, cur_cave)

    Enum.reduce(dest_caves, [], fn dest_cave, acc ->
      dest_cave_visited_value = Map.get(visited_caves, dest_cave, 0)

      cond do
        !is_small_cave(dest_cave) ->
          [dest_cave | acc]

        is_small_cave(dest_cave) and did_double and dest_cave_visited_value < 1 ->
          [dest_cave | acc]

        not did_double and is_small_cave(dest_cave) and Map.get(visited_caves, dest_cave, 0) < 2 ->
          [dest_cave | acc]

        true ->
          acc
      end
    end)
  end

  def dsf_search_step2(_graph, _visited_caves, _did_double, [], paths_found), do: paths_found

  def dsf_search_step2(graph, visited_caves, did_double, [cur_cave | rest], paths_found) do
    next_caves = get_next_caves2(cur_cave, graph, visited_caves, did_double)

    Enum.reduce(next_caves, paths_found, fn next_cave, acc_paths_found ->
      cond do
        next_cave == "end" ->
          [[next_cave, cur_cave | rest] | acc_paths_found]

        true ->
          cur_dest_next_visited_count = Map.get(visited_caves, next_cave, 0) + 1

          dsf_search_step2(
            graph,
            Map.put(visited_caves, next_cave, cur_dest_next_visited_count),
            did_double or (is_small_cave(next_cave) and cur_dest_next_visited_count >= 2),
            [next_cave, cur_cave | rest],
            acc_paths_found
          )
      end
    end)
  end

  def solve2 do
    paths =
      read_file()
      |> dsf_search_step2(%{"start" => 2}, false, ["start"], [])
      |> Enum.map(fn path ->
        path
        |> Enum.reverse()
        |> Enum.join(",")
      end)

    {paths, length(paths)}
  end
end

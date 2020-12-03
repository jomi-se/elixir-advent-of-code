defmodule MapCount do
  def read_file() do
    {:ok, contents} = File.read("input/3.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {string, y}, {acc, _, _} ->
      {tree_map, max_x} =
        string
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(
          {acc, 0},
          fn {char, x}, {int_acc, _} -> {Map.put(int_acc, {x, y}, char), x} end
        )

      {tree_map, max_x, y}
    end)
  end

  def get_pos(x, y, map, max_x, max_y) when x > max_x,
    do: get_pos(rem(x, max_x + 1), y, map, max_x, max_y)

  def get_pos(_x, y, _map, _max_x, max_y) when y > max_y, do: nil
  def get_pos(x, y, map, _max_x, _max_y), do: map[{x, y}]

  def do_count({_cur_x, cur_y}, count, {_map, _max_x, max_y}, _) when cur_y > max_y, do: count

  def do_count({cur_x, cur_y}, count, {map, max_x, max_y}, {move_x, move_y}) do
    char = get_pos(cur_x, cur_y, map, max_x, max_y)

    new_count =
      count +
        case char do
          "#" -> 1
          _ -> 0
        end

    do_count({cur_x + move_x, cur_y + move_y}, new_count, {map, max_x, max_y}, {move_x, move_y})
  end

  def count_trees() do
    {map, max_x, max_y} = read_file()
    do_count({0, 0}, 0, {map, max_x, max_y}, {3, 1})
  end

  def count_trees2() do
    {map, max_x, max_y} = read_file()

    [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]
    |> Enum.reduce(
      1,
      fn move_pos, acc ->
        acc * do_count({0, 0}, 0, {map, max_x, max_y}, move_pos)
      end
    )
  end
end

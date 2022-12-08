defmodule DirCrawling2 do
  def read_file() do
    File.read!("./years/aoc2022/input/7.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
  end

  def get_dir_shallow_size([], acc), do: {acc, []}

  def get_dir_shallow_size([line | rest], acc) do
    [size, _name | _rest] = line

    case size do
      "$" ->
        {acc, [line | rest]}

      "dir" ->
        get_dir_shallow_size(rest, acc)

      _ ->
        get_dir_shallow_size(rest, acc + String.to_integer(size))
    end
  end

  @spec get_next_prefix(any, any) :: nonempty_binary
  def get_next_prefix(_, "/"), do: "/"
  def get_next_prefix(prefix, dirname), do: "#{prefix}/#{dirname}"

  def handle_command([], _prefix, size_map), do: {size_map, []}

  def handle_command([command_line | rest], prefix, size_map) do
    [command_start, command | command_rest] = command_line

    {result, new_size_maps, pending_commands} =
      case {command_start, command, command_rest} do
        {"$", "cd", [".."]} ->
          # :stop lets the iterator stop iterating at this prefix and exit upwards
          {:stop, size_map, rest}

        {"$", "cd", [dir]} ->
          next_prefix = get_next_prefix(prefix, dir)

          {new_size_map, rest_commands} = handle_command(rest, next_prefix, size_map)

          new_size_map2 =
            Map.put(
              new_size_map,
              prefix,
              Map.get(new_size_map, prefix, 0) + Map.fetch!(new_size_map, next_prefix)
            )

          {:continue, new_size_map2, rest_commands}

        {"$", "ls", []} ->
          {dir_size, rest_commands} = get_dir_shallow_size(rest, 0)
          new_size_map = Map.put(size_map, prefix, dir_size)
          {:continue, new_size_map, rest_commands}
      end

    case result do
      :stop ->
        {new_size_maps, pending_commands}

      :continue ->
        handle_command(pending_commands, prefix, new_size_maps)
    end
  end

  def solve1() do
    {size_map, []} =
      read_file()
      |> handle_command("", %{})

    size_map
    |> Map.to_list()
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.filter(fn size -> size <= 100_000 end)
    |> Enum.sum()
  end

  def solve2() do
    {sizes_map, []} =
      read_file()
      |> handle_command("", %{})

    unused_space = 70_000_000 - Map.fetch!(sizes_map, "/")
    needed_space = 30_000_000 - unused_space

    sizes_map
    |> Map.to_list()
    |> Enum.sort(fn {_, sizeA}, {_, sizeB} -> sizeA <= sizeB end)
    |> Enum.find(nil, fn {_name, size} -> size >= needed_space end)
  end
end

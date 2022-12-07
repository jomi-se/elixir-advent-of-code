defmodule DirCrawling do
  def read_file() do
    File.read!("./years/aoc2022/input/7.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
  end

  def change_dir([".."], rest_commands, current_dir), do: {rest_commands, current_dir}

  def change_dir([dir_name], rest_commands, current_dir) do
    new_current_dir = Map.fetch!(current_dir.dirs, dir_name)
    crawler(rest_commands, new_current_dir)
  end

  def list_current_dir([], current_dir), do: {[], current_dir}

  def list_current_dir(
        [line | rest],
        current_dir
      ) do
    [first, second | _rest] = line

    case first do
      "$" ->
        crawl_dirs([line | rest], current_dir)

      _ ->
        case first do
          "dir" ->
            [_, name] = [first, second]

            new_dir = %{
              :name => name,
              :dirs => %{},
              :files => []
            }

            new_current_dir = %{current_dir | :dirs => Map.put(current_dir.dirs, name, new_dir)}

            list_current_dir(rest, new_current_dir)

          _ ->
            [size, name] = [first, second]
            new_file = {name, String.to_integer(size)}
            new_current_dir = %{current_dir | :files => [new_file | current_dir.files]}

            list_current_dir(rest, new_current_dir)
        end
    end
  end

  def crawl_dirs([], current_dir), do: {[], current_dir}

  def crawl_dirs([command_line | rest], current_dir) do
    IO.inspect({command_line, current_dir})
    [is_command, command | command_rest] = command_line

    case {is_command, command} do
      {"$", "cd"} ->
        case command_rest do
          [".."] ->
            {rest, nil}

          [dir_name] ->
            new_current_dir = Map.fetch!(current_dir.dirs, dir_name)
            crawl_dirs(rest, new_current_dir)
        end

      {"$", "ls"} ->
        list_current_dir(rest, current_dir)
    end
  end

  def crawler([], current_dir), do: current_dir

  def crawler(commands, current_dir) do
    {rest_commands, new_current_dir} = crawl_dirs(commands, current_dir)

    case new_current_dir do
      nil ->
        crawler(rest_commands, current_dir)

      _ ->
        crawler(rest_commands, new_current_dir)
    end
  end

  def get_deep_dir_sizes(cur_dir, sizes, prefix) do
    {sum_dir_sizes, new_sizes} =
      Enum.reduce(cur_dir.dirs, {0, sizes}, fn {dirName, dir}, {acc_sum, acc_sizes} ->
        new_prefix =
          case prefix do
            "/" -> "#{prefix}#{dirName}"
            _ -> "#{prefix}/#{dirName}"
          end

        new_acc_sizes = get_deep_dir_sizes(dir, acc_sizes, new_prefix)

        {acc_sum + Map.fetch!(new_acc_sizes, new_prefix), new_acc_sizes}
      end)

    file_sizes = cur_dir.files |> Enum.map(fn {_, size} -> size end) |> Enum.sum()
    Map.put(new_sizes, prefix, file_sizes + sum_dir_sizes)
  end

  def solve1() do
    [["$" | _rest] | rest] = read_file()
    top_dir = %{:name => "/", :dirs => %{}, :files => []}

    {[], new_top_dir} =
      crawler(rest, top_dir)
      |> IO.inspect()

    get_deep_dir_sizes(new_top_dir, %{}, "/")
    |> Map.to_list()
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.filter(fn size -> size <= 100_000 end)
    |> Enum.sum()
  end
end

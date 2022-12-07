defmodule DirCrawling do
  def read_file() do
    File.read!("./input/7.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
  end

  def change_dir([dir_name], rest_commands, current_dir, all_dirs) do
    new_current_dir = Map.fetch!(all_dirs, dir_name)
    crawl_dirs(rest_commands, new_current_dir, %{all_dirs | current_dir.name => current_dir })
  end

  def list_current_dir(
    [line | rest],
    current_dir,
    all_dirs) do

    %{
      :name => name,
      :dirs => dirs,
      :files => files
    } = current_dir
    [first, second | rest] =  line

    case first do
      "$" -> crawl_dirs([line | rest], current_dir, all_dirs)
    _ ->

    end
  end

  def crawl_dirs([command_line | rest], current_dir, all_dirs) do
    [is_command, command | command_rest]  = command_line

    case {is_command, command} do
      {"$", "cd"} -> change_dir(command_rest, rest, current_dir, all_dirs)
      {"$", "ls"} -> list_current_dir(rest, current_dir, all_dirs)

    end
  end

  def solve1() do
    ["$ cd /" | rest] = read_file()
    top_dir = %{:name => "/", :dirs => [], :files => []}
    all_dirs = %{ top_dir.name => top_dir }
    result_map = crawl_dirs(rest, top_dir, all_dirs)
  end
end

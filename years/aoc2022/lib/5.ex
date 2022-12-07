defmodule CratesCrane do
  def read_file() do
    {:ok, contents} = File.read("input/5.txt")

    [crates_raw, moves_raw] = String.split(contents, "\n\n", trim: true)

    crates_parsed =
      crates_raw
      |> String.split("\n")
      |> Enum.map(fn str ->
        str
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {_, index} -> rem(index - 1, 4) == 0 end)
        |> Enum.map(fn {char, _} -> char end)
      end)
      |> transpose()
      |> Enum.map(fn columns ->
        new_cols =
          columns |> Enum.reject(fn char -> char == " " || Regex.match?(~r/^\d+$/, char) end)

        col_num = List.last(columns)
        {col_num, new_cols}
      end)
      |> Map.new()

    moves_parsed =
      moves_raw
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        %{"count" => count, "src" => src, "dest" => dest} =
          Regex.named_captures(~r/^move (?<count>\d+) from (?<src>\d+) to (?<dest>\d+)$/, str)

        {String.to_integer(count), src, dest}
      end)

    {crates_parsed, moves_parsed}
  end

  def transpose(list_of_list) do
    Enum.zip(list_of_list) |> Enum.map(&Tuple.to_list/1)
  end

  def appply_move({0, _src, _dest}, crates), do: crates

  def appply_move({count, src, dest}, crates) do
    %{^src => src_column, ^dest => dest_column} = crates

    [to_move | rest_src] = src_column

    appply_move({count - 1, src, dest}, %{
      crates
      | src => rest_src,
        dest => [to_move | dest_column]
    })
  end

  def print_top(crate) do
    Map.to_list(crate)
    |> Enum.sort(fn {a, _}, {b, _} -> String.to_integer(a) <= String.to_integer(b) end)
    |> Enum.map_join(
      "",
      fn
        {_pos, []} -> ""
        {_pos, [first | _rest]} -> first
      end
    )
  end

  def solve1() do
    {crates, moves} = read_file()

    moves
    |> Enum.reduce(crates, fn move, acc_crates -> appply_move(move, acc_crates) end)
    |> print_top()
  end

  def appply_move2({count, src, dest}, crates) do
    %{^src => src_column, ^dest => dest_column} = crates

    to_move = Enum.take(src_column, count)
    rest_src = Enum.drop(src_column, count)

    %{
      crates
      | src => rest_src,
        dest => to_move ++ dest_column
    }
  end

  def solve2() do
    {crates, moves} = read_file()

    moves
    |> Enum.reduce(crates, fn move, acc_crates -> appply_move2(move, acc_crates) end)
    |> IO.inspect()
    |> print_top()
  end
end

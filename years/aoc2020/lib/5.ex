defmodule SeatFinder do
  def get_boarding_pass_stream() do
    File.stream!("./input/5.txt")
    |> Stream.map(fn string ->
      string
      |> String.trim("\n")
      |> String.graphemes()
    end)
  end

  def get_range_half({start_num, end_num}, col_range, "F"),
    do: {{start_num, div(start_num + end_num, 2)}, col_range}

  def get_range_half(row_range, {start_num, end_num}, "L"),
    do: {row_range, {start_num, div(start_num + end_num, 2)}}

  def get_range_half({start_num, end_num}, col_range, "B"),
    do: {{div(start_num + end_num, 2) + 1, end_num}, col_range}

  def get_range_half(row_range, {start_num, end_num}, "R"),
    do: {row_range, {div(start_num + end_num, 2) + 1, end_num}}

  def get_id([], {row_start, row_end}, {col_start, col_end})
      when row_start == row_end and col_start == col_end do
    row_start * 8 + col_start
  end

  def get_id([head | tail], row_range, col_range) do
        {new_row_range, new_col_range} = get_range_half(row_range, col_range, head)
        get_id(tail, new_row_range, new_col_range)
  end

  def get_max_id() do
    get_boarding_pass_stream()
    |> Enum.reduce(0, fn boarding, max_id ->
      max(max_id, get_id(boarding, {0, 127}, {0, 7}))
    end)
  end

  def find_missing([head| tail]) when head < 6, do: find_missing(tail)
  def find_missing([head| tail]) when head > 127 * 8, do: find_missing(tail)
  def find_missing([head, next| _]) when next - head > 1, do: head + 1
  def find_missing([_| tail]), do: find_missing(tail)

  def get_missing_boarding_pass do
    get_boarding_pass_stream()
    |> Enum.map(&(get_id(&1, {0, 127}, {0, 7})))
    |> Enum.sort()
    |> find_missing()
  end
end

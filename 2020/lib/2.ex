defmodule PasswordChecking do
  def read_file() do
    {:ok, contents} = File.read("input/2.txt")

    String.split(contents, "\n", trim: true)
    |> Enum.map(fn string ->
      [range_raw, letter_raw, password] = String.split(string, " ")
      range = range_raw |> String.split("-") |> Enum.map(&String.to_integer(&1))
      letter = String.first(letter_raw)
      {letter, range, password}
    end)
  end

  def check_password(letter, range, password) do
    freqs = password |> String.graphemes() |> Enum.frequencies()
    count = Map.get(freqs, letter, 0)
    [min, max] = range
    count >= min && count <= max
  end

  def check_password_pos(letter, range, password) do
    [pos1, pos2] = range |> Enum.map(fn pos -> String.at(password, pos - 1) == letter end)
    pos1 != pos2
  end

  def count_valid do
    lines = read_file()

    Enum.count(lines, fn {letter, range, password} ->
      check_password(letter, range, password)
    end)
  end

  def count_valid2 do
    lines = read_file()

    Enum.count(lines, fn {letter, range, password} ->
      check_password_pos(letter, range, password)
    end)
  end
end

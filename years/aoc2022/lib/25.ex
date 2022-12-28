defmodule HotAir do
  def read_file() do
    File.read!("./years/aoc2022/input/25.txt")
    |> String.split("\n", trim: true)
  end

  def snafu_val_to_dec("-"), do: -1
  def snafu_val_to_dec("="), do: -2
  def snafu_val_to_dec(num_str), do: String.to_integer(num_str)

  def snafu_to_dec(num_str) do
    String.graphemes(num_str)
    |> Enum.reverse()
    |> Enum.map(&snafu_val_to_dec(&1))
    |> Enum.with_index()
    |> Enum.reduce(0, fn {val, index}, acc ->
      acc + val * (:math.pow(5, index) |> round)
    end)
  end

  def bump_digs([], acc), do: ["1" | acc] |> Enum.reverse()

  def bump_digs([dig | rest], acc) do
    # IO.inspect(binding(), label: "bumping")
    bumped = String.to_integer(dig) + 1

    case bumped do
      n when n >= 5 ->
        case rest do
          [] ->
            ["1", "0" | acc] |> Enum.reverse()

          [next | rest_2] ->
            bump_digs([next | rest_2], [0 | acc])
        end

      _ ->
        ([bumped |> Integer.to_string() | acc] |> Enum.reverse()) ++ rest
    end
  end

  def dec_to_snafu([], acc), do: acc |> Enum.join("")

  def dec_to_snafu(["4" | rest], acc) do
    # IO.inspect(binding(), label: "4")

    bumped_rest =
      bump_digs(rest, [])
      # |> IO.inspect(label: "bumped_rest")

    dec_to_snafu(bumped_rest, ["-" | acc])
  end

  def dec_to_snafu(["3" | rest], acc) do
    # IO.inspect(binding(), label: "3")

    bumped_rest =
      bump_digs(rest, [])
      # |> IO.inspect(label: "bumped_rest")

    dec_to_snafu(bumped_rest, ["=" | acc])
  end

  def dec_to_snafu([dig | rest], acc) do
    # IO.inspect(binding(), label: "num")
    dec_to_snafu(rest, [dig | acc])
  end

  def dec_to_snafu(num) when is_integer(num) do
    reversed_digs =
      Integer.to_string(num, 5)
      |> String.graphemes()
      |> Enum.reverse()

    dec_to_snafu(reversed_digs, [])
  end

  def solve1 do
    sum =
      read_file()
      |> Enum.map(fn v -> snafu_to_dec(v) end)
      |> IO.inspect()
      |> Enum.sum()
      |> IO.inspect()

    dec_to_snafu(sum)
    |> IO.inspect()
    |> snafu_to_dec()
  end

  def test_change(num) do
    num
    |> IO.inspect()
    |> dec_to_snafu()
    |> IO.inspect()
    |> snafu_to_dec()
  end

  def find_error() do
    97..99
    |> Enum.reduce(0, fn v, _ ->
      case test_change(v) do
        d when d == v ->
          {:cont, d}
          |> IO.inspect()

        _ ->
          {:halt, v}
      end
    end)
  end
end

defmodule Beacon do
  def read_file() do
    File.read!("./years/aoc2022/input/15.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"sensor" => sensor_str, "beacon" => beacon_str} =
        Regex.named_captures(
          ~r/^Sensor.+(?<sensor>x=-?\d+, y=-?\d+): closest.+(?<beacon>x=-?\d+, y=-?\d+)$/,
          line
        )

      [sx, sy] =
        sensor_str
        |> String.split(", ", trim: true)
        |> Enum.map(fn str ->
          [_, num_str] = String.split(str, "=")
          String.to_integer(num_str)
        end)

      [bx, by] =
        beacon_str
        |> String.split(", ", trim: true)
        |> Enum.map(fn str ->
          [_, num_str] = String.split(str, "=")
          String.to_integer(num_str)
        end)

      {{sx, sy}, {bx, by}}
    end)
  end

  defguard is_in_manh_dist(x1, y1, x2, y2, dist) when abs(x1 - x2) + abs(y1 - y2) <= dist

  def manh_dist({sx, sy}, {bx, by}) do
    abs(sx - bx) + abs(sy - by)
  end

  def paint_map_line({sx, sy}, {bx, by}, map, y_line) do
    dist = abs(sx - bx) + abs(sy - by)

    cond do
      sy - (dist + 1) > y_line or sy + dist < y_line ->
        map

      true ->
        for x <- (sx - (dist + 1))..(sx + (dist + 1)),
            is_in_manh_dist(sx, sy, x, y_line, dist) and {x, y_line} != {sx, sy} and
              {x, y_line} != {bx, by},
            into: map do
          {{x, y_line}, "#"}
        end

        # |> Map.put({sx, sy}, "S")
        # |> Map.put({bx, by}, "B")
    end
  end

  def paint_map({sx, sy}, {bx, by}, map) do
    dist = abs(sx - bx) + abs(sy - by)

    cond do
      sy - dist > map.max_y or sy + dist < map.min_y or
        sx - dist > map.max_x or sx + dist < map.min_x ->
        map

      true ->
        for x <- (sx - (dist + 1))..(sx + (dist + 1)),
            y <-
              (sy - (dist + 1))..(sy + (dist + 1)),
            is_in_manh_dist(sx, sy, x, y, dist) and
              x >= map.min_x and x <= map.max_x and
              y >= map.min_y and y <= map.max_y,
            into: map do
          {{x, y}, "#"}
        end
        |> Map.put({sx, sy}, "S")
        |> Map.put({bx, by}, "B")
    end
  end

  def get_row({x, y}, map, acc) when x > map.max_x + 1 or y > map.max_y + 1,
    do: Enum.reverse(acc)

  def get_row({x, y}, map, acc) when x <= map.max_x + 1 do
    val =
      case Map.get(map, {x, y}) do
        nil -> "."
        value -> value
      end

    get_row({x + 1, y}, map, [val | acc])
  end

  def get_rows(y, map, acc) do
    case get_row({map.min_x - 1, y}, map, []) do
      [] -> Enum.reverse(acc)
      row -> get_rows(y + 1, map, [row | acc])
    end
  end

  def print_map(map) do
    get_rows(map.min_y - 1, map, [])
    |> Enum.map_join("\n", fn row -> Enum.join(row, "") end)
    |> IO.puts()

    IO.puts("")

    map
  end

  def count_non_empty_in_line(map, y) do
    for x <- (map.min_x - 1)..(map.max_x + 1) do
      Map.get(map, {x, y})
    end
    |> Enum.filter(fn n -> n != nil end)
    |> length()
  end

  def solve1 do
    lines = read_file()

    Enum.reduce(
      lines,
      %{},
      fn {s, b}, acc_map ->
        paint_map_line(s, b, acc_map, 2_000_000)
      end
    )
    |> map_size()
  end

  def solve_print_example do
    lines = read_file()

    Enum.reduce(
      lines,
      %{
        :min_x => 0,
        :max_x => 20,
        :min_y => 0,
        :max_y => 20
      },
      fn {s, b}, acc_map ->
        paint_map(s, b, acc_map)
      end
    )
    |> Map.put({14, 11}, "O")
    |> print_map()
  end

  def is_covered_by_sensor(_, []), do: false

  def is_covered_by_sensor({x, y}, [{s, b} | rest]) do
    dist = manh_dist(s, b)
    {sx, sy} = s

    cond do
      is_in_manh_dist(x, y, sx, sy, dist) ->
        true

      true ->
        is_covered_by_sensor({x, y}, rest)
    end
  end

  def find_beacon(map, sensors) do
    map.min_y..map.max_y
    |> Enum.reduce_while(nil, fn y, _acc_y ->
      IO.inspect("is slow?")

      val =
        map.min_x..map.max_x
        |> Enum.reduce_while(nil, fn x, _acc_x ->
          cond do
            is_covered_by_sensor({x, y}, sensors) -> {:halt, {x, y}}
            true -> {:cont, nil}
          end
        end)
        |> IO.inspect()

      case val do
        nil -> {:cont, nil}
        val -> {:halt, val}
      end
    end)
  end

  def get_intervals_for_pair({sx, sy}, {bx, by}, y, min_x, max_x) do
    dist = manh_dist({sx, sy}, {bx, by})
    x_gt = dist - abs(y - sy) + sx
    x_lt = abs(y - sy) + sx - dist

    cond do
      x_lt > x_gt ->
        [{min_x, max_x}]

      true ->
        [{min_x, x_lt}, {x_gt, max_x}]
        |> Enum.filter(fn {x1, x2} -> x2 > x1 end)
    end
  end

  def intersect_intervals([], []), do: []
  def intersect_intervals([], _int2), do: []
  def intersect_intervals(_int1, []), do: []

  def intersect_intervals([{xs1, xe1}], [{xs2, xe2}]) do
    # IO.inspect({[{xs1, xe1}], [{xs2, xe2}]}, label: "intersect")
    cond do
      xe1 <= xs2 or xe2 <= xs1 ->
        []

      true ->
        [{max(xs1, xs2), min(xe1, xe2)}]
    end

    # |> IO.inspect(label: "result")
  end

  def intersect_intervals([{xs1, xe1}], [i1, i2]) do
    int1 = intersect_intervals([{xs1, xe1}], [i1])
    int2 = intersect_intervals([{xs1, xe1}], [i2])
    int1 ++ int2
  end

  def intersect_intervals([i1, i2], [{xs1, xe1}]), do: intersect_intervals([{xs1, xe1}], [i1, i2])

  def intersect_intervals(ints1, ints2) do
    Enum.reduce(ints1, [], fn i1, acc_intersects ->
      acc_intersects ++
        Enum.reduce(ints2, [], fn i2, acc_intersects_2 ->
          acc_intersects_2 ++ intersect_intervals([i1], [i2])
        end)
    end)
  end

  def solve2 do
    lines = read_file()

    min_val = 0
    max_val = 4_000_000

    {x, y} =
      min_val..max_val
      |> Enum.reduce_while(nil, fn y, _acc ->
        intervals_for_line =
          Enum.map(lines, fn {s, b} -> get_intervals_for_pair(s, b, y, min_val, max_val) end)

        # IO.inspect(intervals_for_line, label: "#{y}")

        result =
          Enum.reduce_while(intervals_for_line, [{min_val, max_val}], fn interval, base_int ->
            result = intersect_intervals(base_int, interval)

            case result do
              [] -> {:halt, nil}
              val -> {:cont, val}
            end
          end)

        # IO.inspect(result, label: "#{y}")

        case result do
          nil -> {:cont, nil}
          [{min_x, _max_x}] -> {:halt, {min_x + 1, y}}
        end
      end)
      |> IO.inspect()

    x * 4_000_000 + y
  end
end

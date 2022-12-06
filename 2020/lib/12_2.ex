defmodule Movimiento2 do
  def get_command_stream() do
    File.stream!("./input/12.txt")
    |> Stream.map(fn string ->
      {instruction, num_str} =
        string
        |> String.trim("\n")
        |> String.split_at(1)

      {instruction, String.to_integer(num_str)}
    end)
  end

  def rotate_waypoint({way_pos_x, way_pos_y}, clockwise_angle) do
    case clockwise_angle do
      0 -> { way_pos_x,   way_pos_y}
      90 -> { way_pos_y,  - way_pos_x}
      180 -> {- way_pos_x,  - way_pos_y}
      270 -> {- way_pos_y,  way_pos_x}
    end
  end

  def get_next_pos(command, pos_and_waypoint_pos)

  def get_next_pos({"N", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: {{pos_x, pos_y}, {way_pos_x, way_pos_y + value}}

  def get_next_pos({"S", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: {{pos_x, pos_y}, {way_pos_x, way_pos_y - value}}

  def get_next_pos({"E", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: {{pos_x, pos_y}, {way_pos_x + value, way_pos_y}}

  def get_next_pos({"W", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: {{pos_x, pos_y}, {way_pos_x - value, way_pos_y}}

  def get_next_pos({"L", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: get_next_pos({"R", 360 - value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}})

  def get_next_pos({"R", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: {{pos_x, pos_y}, rotate_waypoint({way_pos_x, way_pos_y}, value)}

  def get_next_pos({"F", value}, {{pos_x, pos_y}, {way_pos_x, way_pos_y}}),
    do: {{pos_x + value * way_pos_x, pos_y + value * way_pos_y}, {way_pos_x, way_pos_y}}

  def part_2 do
    {{pos_x, pos_y}, _} =
      get_command_stream()
      |> Enum.reduce({{0, 0}, {10, 1}}, fn command, acc ->
        get_next_pos(command, acc) |> IO.inspect()
      end)

    IO.inspect({pos_x, pos_y})
    abs(pos_x) + abs(pos_y)
  end
end

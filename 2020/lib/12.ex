defmodule Movimiento do
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

  def get_dir(dir, clockwise_rotate) do
   cur_angle = case dir do
      "N" -> 0
      "E" -> 90
      "S" -> 180
      "W" -> 270
               end
   next_angle = rem(cur_angle + clockwise_rotate, 360)
   case next_angle do
       0 -> "N"
       90 -> "E"
       180 -> "S"
       270 -> "W"
   end
  end

  def get_next_pos(command, pos)
  def get_next_pos({"N", value}, {pos_x, pos_y, dir}), do: {pos_x, pos_y + value, dir}
  def get_next_pos({"S", value}, {pos_x, pos_y, dir}), do: {pos_x, pos_y - value, dir}
  def get_next_pos({"E", value}, {pos_x, pos_y, dir}), do: {pos_x + value, pos_y, dir}
  def get_next_pos({"W", value}, {pos_x, pos_y, dir}), do: {pos_x - value, pos_y, dir}
  def get_next_pos({"L", value}, {pos_x, pos_y, dir}), do: get_next_pos({"R", 360 - value}, {pos_x, pos_y, dir})
  def get_next_pos({"R", value}, {pos_x, pos_y, dir}), do: {pos_x, pos_y, get_dir(dir, value)}
  def get_next_pos({"F", value}, {pos_x, pos_y, dir = "N"}), do: {pos_x, pos_y + value, dir}
  def get_next_pos({"F", value}, {pos_x, pos_y, dir = "S"}), do: {pos_x, pos_y - value, dir}
  def get_next_pos({"F", value}, {pos_x, pos_y, dir = "E"}), do: {pos_x + value, pos_y, dir}
  def get_next_pos({"F", value}, {pos_x, pos_y, dir = "W"}), do: {pos_x - value, pos_y, dir}

  def part_1 do
    {pos_x, pos_y, dir} = get_command_stream()
    |> Enum.reduce({0, 0, "E"}, &get_next_pos/2)

    IO.inspect({pos_x, pos_y, dir})
    abs(pos_x) + abs(pos_y)
  end

end

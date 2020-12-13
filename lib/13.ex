defmodule Buses do
  def read_file!() do
    {:ok, contents} = File.read("input/13.txt")

    [time, buses] = String.split(contents, "\n", trim: true)

    bus_ids =
      buses
      |> String.split(",")
      |> Enum.filter(&(&1 != "x"))
      |> Enum.map(&String.to_integer(&1))

    {String.to_integer(time), bus_ids}
  end

  def part_1 do
    {timestamp, buses} = read_file!()

    {bus_id, depart_time} =
      buses
      |> Enum.map(fn bus ->
        case rem(timestamp, bus) do
          0 -> {bus, timestamp}
          _ -> {bus, timestamp + bus - rem(timestamp, bus)}
        end
      end)
      |> Enum.min_by(fn {_, bustime} -> bustime end)

    bus_id * (depart_time - timestamp)
  end

  def read_file_2!() do
    {:ok, contents} = File.read("input/13.txt")

    [_, buses] = String.split(contents, "\n", trim: true)

    buses
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.filter(fn {elem, _} -> elem != "x" end)
    |> Enum.map(fn {elem_str, index} -> {String.to_integer(elem_str), index} end)
  end

  def part_2 do
    buses = read_file_2!()

    buses
    |> Enum.sort_by(fn {elem, _} -> -elem end)
    |> find_common_step_for_all()
    |> find_smallest_timestamp()

  end

  def find_smallest_timestamp({largest_bus, mult, step}) do
    smallest_mult = rem(mult, step)
    {id, index} = largest_bus
    id * smallest_mult - index
  end

  def find_common_step_for_all([largest_bus | tail]) do
   {mult, step} = tail
    |> Enum.reduce({1, 1}, fn (bus, {mult, step})->
      find_common_step_2(largest_bus, bus, mult, step)
      |> IO.inspect()
   end)

   {largest_bus, mult, step}
  end

  def find_common_step_2(bus_a, bus_b, mult, step) do
    mult_start = find_first_matching(bus_a, bus_b, mult, step)
    mult_end = find_first_matching(bus_a, bus_b, mult_start + step, step)
    new_step = mult_end - mult_start
    {mult_end, new_step}
  end

  def find_first_matching(bus_a, bus_b, mult, step) do
    {a_id, a_index} = bus_a
    {b_id, b_index} = bus_b
    timestamp_0 = a_id * mult - a_index
    is_match = rem(timestamp_0 + b_index, b_id) == 0
    case is_match do
        true -> mult
        false -> find_first_matching(bus_a, bus_b, mult + step, step)
    end
  end

end

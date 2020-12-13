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

    [head | tail] = buses
    |> Enum.sort_by(fn {elem, _} -> -elem end)

    {mult, step} = find_common_step(head, tail, 1, 1)
    find_lowest_timestamp(head, tail, mult, step)
  end

  def find_lowest_timestamp(head, tail, mult, step) do
    {first_id, f_index} = head
    target_timestamp = first_id * mult - f_index
    IO.inspect({mult, step})

    is_solution = Enum.all?(tail, fn ({id, index}) -> rem(target_timestamp + index, id) == 0 end) && mult > 0
    case is_solution do
      false -> first_id * (mult + step) - f_index
      true -> find_lowest_timestamp(head, tail, mult - step, step)
      end
  end

  def find_common_step(_, [], mult, step) do
    {mult,step}
  end

  def find_common_step(first, [head | buses], mult, step) do
    {first_id, f_index} = first
    target_timestamp = first_id * mult - f_index

    {bus_id, h_index} = head
    IO.inspect({first_id, bus_id, mult, step, rem(target_timestamp + h_index, bus_id)})
    match = rem(target_timestamp + h_index, bus_id) == 0
    if match do
      find_common_step(first, [head| buses], mult + step, step, mult)
    else
      find_common_step(first, [head| buses], mult + step, step)
    end
  end

  def find_common_step(first, [head | buses], mult, step, prev_mult_match) do
    {first_id, f_index} = first
    target_timestamp = first_id * mult - f_index

    {bus_id, h_index} = head
    IO.inspect({first_id, bus_id, mult, step, rem(target_timestamp + h_index, bus_id)})
    match = rem(target_timestamp + h_index, bus_id) == 0
    if match do
      find_common_step(first, buses, mult, mult - prev_mult_match)
    else
      find_common_step(first, [head| buses], mult + step, step, prev_mult_match)
    end
  end
end

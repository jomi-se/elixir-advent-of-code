defmodule Last do
  def read_file do
    File.read!("./input/25.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.to_integer(&1)))
  end

  @remainder 20201227

  def find_loop_size(_subject_number, value, target, count) when value == target, do: count
  def find_loop_size(subject_number, value, target, count) do
    mult = value * subject_number
    next_num = rem(mult, @remainder)

    find_loop_size(subject_number, next_num, target, count + 1)
  end

  def get_encryption_key(_subject_number, value, 0), do: value
  def get_encryption_key(subject_number, value, count) do
    mult = value * subject_number
    next_num = rem(mult, @remainder)

    get_encryption_key(subject_number, next_num, count - 1)
  end

  def part_1 do
    [card_pkey, door_pkey] = read_file()
    card_loop_size = find_loop_size(7, 1, card_pkey, 0)
    door_loop_size = find_loop_size(7, 1, door_pkey, 0)


    enc1 = get_encryption_key(door_pkey, 1, card_loop_size)
    |> IO.inspect()
    enc2 = get_encryption_key(card_pkey, 1, door_loop_size)
    |> IO.inspect()
  end
end

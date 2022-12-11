defmodule Monkeys2 do
  @type monkey :: %{
          monkey_name: String.t(),
          items_queue: :queue.t(integer()),
          operation_fn: (integer() -> integer()),
          throw_to_monkey_fn: (integer() -> String.t()),
          inspect_count: integer()
        }
  @type changing_item_queues :: %{String.t() => :queue.t()}
  @spec read_file ::
          list(monkey())
  def read_file do
    File.read!("./years/aoc2022/input/11.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn str_data ->
      [
        monkey_name_line_str,
        starting_items_str,
        operation_line_str,
        test_str,
        condition_true,
        condition_false
      ] =
        str_data
        |> String.split("\n", trim: true)

      "Monkey " <> monkey_name_str = monkey_name_line_str
      monkey_name = String.replace(monkey_name_str, ":", "")
      "  Starting items: " <> starting_items = starting_items_str

      starting_items_queue =
        :queue.from_list(starting_items |> String.split(", ") |> Enum.map(&String.to_integer(&1)))

      "  Operation: new = " <> operation_str = operation_line_str
      [val1, operator, val2] = operation_str |> String.split(" ")

      operation_fn = fn item_value ->
        left =
          case val1 do
            "old" -> item_value
            _ -> String.to_integer(val1)
          end

        right =
          case val2 do
            "old" -> item_value
            _ -> String.to_integer(val2)
          end

        case operator do
          "+" ->
            left + right

          "*" ->
            left * right
        end
      end

      "  Test: divisible by " <> divisor_str = test_str
      divisor = String.to_integer(divisor_str)

      "    If true: throw to monkey " <> true_monkey = condition_true
      "    If false: throw to monkey " <> false_monkey = condition_false

      throw_to_monkey_fn = fn item_value ->
        case rem(item_value, divisor) == 0 do
          true -> true_monkey
          false -> false_monkey
        end
      end

      %{
        :monkey_name => monkey_name,
        :items_queue => starting_items_queue,
        :operation_fn => operation_fn,
        :divisor => divisor,
        :throw_to_monkey_fn => throw_to_monkey_fn,
        :inspect_count => 0
      }
    end)
  end

  def handle_monkey_round([], changed_item_queues, monkey_acc),
    do: {monkey_acc |> Enum.reverse(), changed_item_queues}

  @spec handle_monkey_round(
          list(monkey()),
          changing_item_queues(),
          list(monkey())
        ) :: {changing_item_queues(), list(monkey())}
  def handle_monkey_round([cur_monkey | rest], changed_item_queues, monkey_acc) do
    {extra_items, changed_item_queues_after_cur_monkey_remove} =
      Map.pop(changed_item_queues, cur_monkey.monkey_name, :queue.new())

    monkey_item_queue = :queue.join(cur_monkey.items_queue, extra_items)

    {length, new_changed_item_queue} =
      :queue.fold(
        fn item, {length_acc, changed_items_acc} ->
          new_item_val = cur_monkey.operation_fn.(item)
          new_monkey = cur_monkey.throw_to_monkey_fn.(new_item_val)

          {length_acc + 1,
           Map.put(
             changed_items_acc,
             new_monkey,
             :queue.in(new_item_val, Map.get(changed_items_acc, new_monkey, :queue.new()))
           )}
        end,
        {0, changed_item_queues_after_cur_monkey_remove},
        monkey_item_queue
      )

    new_monkey = %{
      cur_monkey
      | :inspect_count => cur_monkey.inspect_count + length,
        :items_queue => :queue.new()
    }

    handle_monkey_round(rest, new_changed_item_queue, [new_monkey | monkey_acc])
  end

  def solve1 do
    monkey_list = read_file()

    common_modulo = Enum.reduce(monkey_list, 1, fn monkey, acc -> acc * monkey.divisor end)

    {result_monkey_list, _} =
      1..10000
      |> Enum.reduce({monkey_list, %{}}, fn val, {monkey_list_acc, changed_item_queues_acc} ->
        if rem(val, 100) == 0 do
          IO.inspect({val})
        end

        {m, i} = handle_monkey_round(monkey_list_acc, changed_item_queues_acc, [])

        new_i =
          Map.to_list(i)
          |> Enum.map(fn {i, queue} ->
            {i, :queue.to_list(queue) |> Enum.map(&rem(&1, common_modulo)) |> :queue.from_list()}
          end)
          |> Map.new()

        {m, new_i}
      end)

    [first, second] =
      result_monkey_list
      |> Enum.sort(fn a, b -> a.inspect_count >= b.inspect_count end)
      |> IO.inspect()
      |> Enum.take(2)

    first.inspect_count * second.inspect_count
  end
end

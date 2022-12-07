defmodule TrainTicket do
  def read_input do
    {:ok, content} = File.read("./input/16.txt")

    [rules, my_ticket, other_tickets] = String.split(content, "\n\n")
    parsed_rules = parse_rules(rules)
    [my_ticket] = parse_tickets(my_ticket)
    other_tickets = parse_tickets(other_tickets)

    {parsed_rules, my_ticket, other_tickets}
  end

  @spec parse_rules(binary) :: [%{field: String.t(), ranges: [[integer()]]}]
  def parse_rules(rules) do
    rules
    |> String.split("\n")
    |> Enum.map(fn line ->
      captures = Regex.named_captures(~r/^(?<field>.+): (?<ranges>.+)$/, line)

      ranges =
        captures["ranges"]
        |> String.split(" or ")
        |> Enum.map(fn str_range ->
          str_range
          |> String.split("-")
          |> Enum.map(&String.to_integer(&1))
        end)

      %{:field => captures["field"], :ranges => ranges}
    end)
  end

  def parse_tickets(tickets) do
    lines = String.split(tickets, "\n", trim: true)
    [_ | tickets_strs] = lines

    tickets_strs
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer(&1))
    end)
  end

  def part_1 do
    {parsed_rules, _my_ticket, other_tickets} = read_input()

    other_tickets
    |> Enum.reduce(0, fn ticket, outer_acc ->
      Enum.reduce(ticket, outer_acc, fn value, acc ->
        is_valid =
          Enum.any?(parsed_rules, fn rule ->
            Enum.any?(rule.ranges, fn [a, b] -> value >= a and value <= b end)
          end)

        case is_valid do
          true -> acc
          false -> acc + value
        end
      end)
    end)
  end

  def part_2 do
    {parsed_rules, my_ticket, other_tickets} = read_input()

    valid_tickets = filter_invalid(other_tickets, parsed_rules)
    ticket_values = ticket_values_by_index([my_ticket | valid_tickets], %{})

    rules_indexes = for rule <- parsed_rules, into: %{}, do: {rule.field, get_indexes_for_rule(rule, ticket_values)}
    sol = assign_rules_to_indexes(rules_indexes, map_size(rules_indexes), %{})
    departure_indexes = for key <- Map.keys(sol), String.starts_with?(key, "departure"), into: %{}, do: {sol[key], true}
    my_ticket
    |> Enum.with_index()
    |> Enum.filter(fn {_,index} -> Map.has_key?(departure_indexes, index) end)
    |> Enum.reduce(1, fn ({value, _}, acc) -> value * acc end)

  end

  def filter_invalid(tickets, rules) do
    tickets
    |> Enum.filter(fn ticket ->
      Enum.all?(ticket, fn value ->
        is_valid =
          Enum.any?(rules, fn rule ->
            Enum.any?(rule.ranges, fn [a, b] -> value >= a and value <= b end)
          end)

        is_valid
      end)
    end)
  end

  def ticket_values_by_index([], acc), do: acc

  def ticket_values_by_index([head | tail], acc) do
    ticket_map = for {val, index} <- Enum.with_index(head), into: %{}, do: {index, [val]}
    merged_map = Map.merge(ticket_map, acc, fn _, v1, v2 -> v1 ++ v2 end)
    ticket_values_by_index(tail, merged_map)
  end

  def get_indexes_for_rule(rule, tickets_by_index) do
    for i <- 0..(map_size(tickets_by_index) - 1),
        is_rule_valid_for_index(tickets_by_index, i, rule),
        into: %{},
        do: {i, true}
  end

  def is_rule_valid_for_index(tickets_by_index, index, rule) do
    ticket_values = tickets_by_index[index]

    Enum.all?(ticket_values, fn value ->
      Enum.any?(rule.ranges, fn [a, b] -> a <= value and value <= b end)
    end)
  end

  def assign_rules_to_indexes(_, total_rules, acc_rules_indexes) when total_rules == map_size(acc_rules_indexes), do: acc_rules_indexes
  def assign_rules_to_indexes(rules_indexes_map, total_rules, acc_rules_indexes) do
   found_rule_field = Map.keys(rules_indexes_map)
   |> Enum.find( fn (key) -> map_size(rules_indexes_map[key]) == 1 end)

   [index] = Map.keys(rules_indexes_map[found_rule_field])
   map_without_found = Map.delete(rules_indexes_map, found_rule_field)
   new_rules_indexes_map = Map.keys(map_without_found) |>
     Enum.reduce(map_without_found, fn (key, acc) ->
       Map.put(acc, key, Map.delete(acc[key], index))
     end)

   new_acc = Map.put(acc_rules_indexes, found_rule_field, index)
   assign_rules_to_indexes(new_rules_indexes_map, total_rules, new_acc)
  end
end

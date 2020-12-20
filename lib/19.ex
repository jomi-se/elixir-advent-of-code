defmodule RuleMatcher do
  def read_file! do
    [rules_str, text_str] =
      File.read!("./input/19.txt")
      |> String.split("\n\n")

    parsed_rules =
      rules_str
      |> String.split("\n")
      |> Enum.map(fn rule_line ->
        [rule_name, rest] = String.split(rule_line, ":")
        rule_num = String.to_integer(rule_name)

        rule_def =
          rest
          |> String.split("|")
          |> Enum.map(fn sub_rule ->
            num_or_str_list = String.split(sub_rule, " ", trim: true)

            case num_or_str_list do
              ["\"a\""] -> "a"
              ["\"b\""] -> "b"
              num_list -> Enum.map(num_list, &String.to_integer(&1))
            end
          end)

        {rule_num, rule_def}
      end)

    messages = text_str |> String.split("\n", trim: true)

    {parsed_rules, messages}
  end

  def rules_to_map([], acc), do: acc

  def rules_to_map([rule | tail], acc) do
    {rule_num, rule_def} = rule
    nwe_acc = Map.put(acc, rule_num, rule_def)
    rules_to_map(tail, nwe_acc)
  end

  def expand_rule(rule_num, rules_map) do
    rule_def = Map.get(rules_map, rule_num)

    case rule_def do
      ["a"] -> ["a"]
      ["b"] -> ["b"]
      rd -> expand_recursive(rd, rules_map)
    end
  end

  def expand_recursive([], _), do: []

  def expand_recursive([first | other_rules], rules_map) do
    expanded_branch =
      Enum.map(first, fn rule_num ->
        expand_rule(rule_num, rules_map)
      end)

    flattened_branch = rules_combine(expanded_branch, [""])
    flattened_branch ++ expand_recursive(other_rules, rules_map)
  end

  def rules_combine([], prefixes), do: prefixes

  def rules_combine([first | rules_expansions], prefixes) do
    new_prefixes =
      for string <- first, prefix <- prefixes, into: [] do
        prefix <> string
      end

    rules_combine(rules_expansions, new_prefixes)
  end

  def expand_all_rules(rules_map) do
    rules = expand_rule(0, rules_map)

    for r <- rules, into: %{}, do: {r, true}
  end

  def part_1 do
    {parsed_rules, text_list} = read_file!()
    rules_map = rules_to_map(parsed_rules, %{})
    rule_checking_map = expand_all_rules(rules_map)

    text_list
    |> Enum.map(&Map.get(rule_checking_map, &1))
    |> Enum.count(fn res -> res == true end)
  end

  def into_map_set(list) do
    for i <- list, into: %{}, do: {i, true}
  end

  def part_2 do
    {parsed_rules, text_list} = read_file!()
    rules_map = rules_to_map(parsed_rules, %{})
    rule_checking_map = expand_all_rules(rules_map)

    base_count =
      text_list
      |> Enum.map(&Map.get(rule_checking_map, &1))
      |> Enum.count(fn res -> res == true end)

    IO.inspect({expand_rule(31, rules_map)})
    IO.inspect({expand_rule(42, rules_map)})
    universe_answer = expand_rule(42, rules_map) |> into_map_set()
    size_42 = Map.keys(universe_answer)
    |> Enum.at(0)
    |> String.length()
    thirty_and_one = expand_rule(31, rules_map) |> into_map_set()
    # After any recursion, solution size > base_solutions size
    extra_count =
      text_list
      |> Enum.filter(&(String.length(&1) >  size_42 * 3))
      # Recursive solution length  are n*42 <> 42 42 42 ... 31 31 31
      # (same number of 42 and 31) for second part
      # 42 and 31 length 8, so number of matching 31 has to be smaller than half the
      # numbers of gorups of 8 chars
      |> Enum.map(fn line_str ->
        eight_length_chunks =
          line_str
          |> Stream.unfold(&String.split_at(&1, size_42))
          |> Enum.take_while(&(&1 != ""))
          |> Enum.reverse()

      IO.inspect({line_str, eight_length_chunks})
      is_match_31(eight_length_chunks, {universe_answer, thirty_and_one}, 1, [])
      |> IO.inspect()
      end)
      |> Enum.count(fn is_match -> is_match == true end)

      IO.inspect({extra_count, base_count})
    extra_count + base_count
  end

  def is_match_31([head | tail], {universe_answer, thirty_and_one}, count_31, list) do
    is_match = Map.get(thirty_and_one, head) == true and count_31 < length(tail)

    case is_match do
      false ->
        false

      true ->
        matches = is_match_31(tail, {universe_answer, thirty_and_one}, count_31 + 1, [31|list])

        case matches do
          true -> true
          false -> is_match_42(tail, {universe_answer, thirty_and_one}, [31|list])
        end
    end
  end

  def is_match_42([], _, list) do
    IO.puts("COUNT DEBUG #{Enum.count(list, &(&1 == 31)) < (length(list) / 2)}")
    IO.inspect(list)
    true
  end

  def is_match_42([head | tail], {universe_answer, thirty_and_one}, list) do
    is_match = Map.get(universe_answer, head) == true

    case is_match do
      true -> is_match_42(tail, {universe_answer, thirty_and_one}, [42|list])
      false -> false
    end
  end
end

#  8+ 42\n31\n

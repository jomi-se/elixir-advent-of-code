defmodule Bags do
  def parse_inner(inner) do
    inner
    |> String.split(",")
    |> Enum.reduce([], fn str, acc ->
      split_str =
        str
        |> String.trim()
        |> String.split(" ")

      case split_str do
        [num, desc, colour, _bags] -> [[String.to_integer(num), desc <> " " <> colour] | acc]
        [_no, _other, _bags] -> acc
      end
    end)
  end

  def get_bag_graph() do
    File.stream!("./input/7.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Enum.reduce([], fn line, acc ->
      %{"outer" => outer, "inner" => inner} =
        Regex.named_captures(
          ~r/^(?<outer>[[:lower:]]+ [[:lower:]]+) bags contain(?<inner>(( no other bags)|( [1-9] [[:lower:]]+ [[:lower:]]+ bags?,?)+))\.$/u,
          line,
          capture: :all_names
        )

      outer_to_inner_pairs =
        parse_inner(inner)
        |> Enum.map(fn [num, parsed_inner] ->
          {outer, parsed_inner, num}
        end)

      outer_to_inner_pairs ++ acc
    end)
  end

  def solve() do
    get_bag_graph()
    |> get_all_ascendants(["shiny gold"])
    |> Kernel.length()
  end

  def get_all_ascendants(graph, target) do
    do_get_all_ascendants(graph, target, [])
  end

  def do_get_all_ascendants(_, [], outers), do: outers

  def do_get_all_ascendants(graph, inners, outers) do
    new_outers = find_outers_to_inners(graph, inners, outers)
    do_get_all_ascendants(graph, new_outers, new_outers ++ outers)
  end

  def find_outers_to_inners(graph, inners, ignored) do
    Enum.reduce(graph, [], fn {outer, inner, _num}, acc ->
      case Enum.member?(inners, inner) && !Enum.member?(ignored ++ acc, outer) do
        true -> [outer | acc]
        false -> acc
      end
    end)
  end

  def solve2() do
    get_bag_graph()
    |> do_count_all_descendants("shiny gold", [], 1)
    |> Kernel.-(1)
  end

  def do_count_all_descendants(graph, outer, already_found, cur_multiplier) do
    new_inners = find_inners_for_outer_with_nums(graph, outer, already_found)

toto =    case new_inners do
      [] ->
        cur_multiplier

      new_inners_int ->
        Enum.map(new_inners_int, fn {inner, num} ->
          do_count_all_descendants(
            graph,
            inner,
            already_found ++ new_inners_int,
            num
          )
        end)
        |> Enum.sum()
        |> Kernel.*(cur_multiplier)
              |> Kernel.+(cur_multiplier)
    end
    IO.inspect({toto, outer, cur_multiplier})
    toto
  end

  def find_inners_for_outer_with_nums(graph, target_outer, ignored) do
    Enum.reduce(graph, [], fn {outer, inner, num}, acc ->
      case target_outer == outer && !Enum.member?(ignored ++ acc, inner) do
        true -> [{inner, num} | acc]
        false -> acc
      end
    end)
  end
end

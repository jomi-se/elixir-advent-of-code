defmodule Allergens do
  def read_file do
    File.read!("./input/21.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{"ing" => ingredients_str, "all" => allergens_str} = Regex.named_captures(~r/^(?<ing>[a-zA-Z ]+) \(contains (?<all>[a-zA-Z, ]+)\)$/, line)
      ingredients = String.split(ingredients_str, " ", trim: true)
      allergens = String.split(allergens_str, ", ", trim: true)
      {ingredients, allergens}
    end)
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}, %{}}, fn ({{ingredients, allergens}, index}, {by_index, by_ingr, by_allerg}) ->
      new_by_index = Map.put(by_index, index, {ingredients, allergens})

      new_by_ingr = ingredients
      |> Enum.reduce(by_ingr, fn (ingredient, acc) ->
        Map.update(acc, ingredient, MapSet.new([index]), &MapSet.put(&1, index))
      end)

      new_by_allerg = allergens
      |> Enum.reduce(by_allerg, fn (allergen, acc) ->
        Map.update(acc, allergen,MapSet.new([index]), &MapSet.put(&1, index))
      end)

      {new_by_index, new_by_ingr, new_by_allerg}
    end)
  end

  def find_candidates_for_allergen(allergen, by_ingredient, by_allergen) do
    by_ingredient
    |> Enum.to_list()
    |> Enum.filter(fn {_, set} ->
      MapSet.subset?(by_allergen[allergen], set)
    end)
    |> Enum.map(fn {name, _} -> name end)
    |> MapSet.new()
  end

  def part_1() do
    {by_index, by_ingr, by_allerg} = read_file()

    all_alergens = Map.keys(by_allerg)
    |> Enum.map(fn allergen ->
      {allergen, find_candidates_for_allergen(allergen, by_ingr, by_allerg)}
    end)
    |> Enum.sort_by(fn {_, set} -> MapSet.size(set) end)
    |> Enum.reduce(MapSet.new(), fn {_, set}, acc ->
      MapSet.union(acc, set)
    end)

    ingredients = by_ingr |> Map.keys() |> MapSet.new()

    non_allergens = MapSet.difference(ingredients, all_alergens)
    by_index
    |> Map.values()
    |> Enum.reduce(0, fn {ingreds, _}, acc ->
      acc + Enum.count(ingreds, &MapSet.member?(non_allergens, &1))
    end)
  end

  def part_2() do
    {_by_index, by_ingr, by_allerg} = read_file()

   Map.keys(by_allerg)
    |> Enum.map(fn allergen ->
      {allergen, find_candidates_for_allergen(allergen, by_ingr, by_allerg)}
    end)
    |> Enum.sort_by(fn {_, set} -> MapSet.size(set) end)
    |> match_allergens([])
    |> Enum.sort_by(fn {allergen, _} -> allergen end)
    |> Enum.map(fn {_allergen, ingredient} -> ingredient end)
    |> Enum.join(",")
  end

  def match_allergens([], matched), do: matched
  def match_allergens([{matched_allergen, set}|rest], matched) do
    if (MapSet.size(set) > 1) do
      IO.inspect({matched_allergen, set})
      raise "Oh NOES"
    end

    [ingredient] = MapSet.to_list(set)
    new_matched = [{matched_allergen, ingredient} | matched]

   sorted_rest = rest
    |> Enum.map(fn {allergen, set} -> {allergen, MapSet.delete(set, ingredient)} end)
    |> Enum.sort_by(fn {_, set} -> MapSet.size(set) end)
    IO.inspect({sorted_rest, new_matched})

   match_allergens(sorted_rest, new_matched)
  end
end

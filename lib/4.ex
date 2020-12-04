defmodule PassportScanner do
  def get_passport_stream() do
    File.stream!("./input/4.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(&do_parse(&1, %{}))
  end

  def do_parse([], map), do: map

  def do_parse([string | tail], map) do
    new_map =
      string
      |> String.split(" ")
      |> Enum.reduce(map, fn str_chunk, acc ->
        [key, val] = String.split(str_chunk, ":")
        Map.put(acc, key, val)
      end)

    do_parse(tail, new_map)
  end

  def count_valid() do
    get_passport_stream()
    |> Enum.count(fn passport ->
      cond do
        map_size(passport) == 8 -> true
        map_size(passport) == 7 && !Map.has_key?(passport, "cid") -> true
        true -> false
      end
    end)
  end

  def count_valid2() do
    get_passport_stream()
    |> Enum.count(fn passport ->
      cond do
        map_size(passport) == 8 && validate_passport(passport) ->
          true

        map_size(passport) == 7 && !Map.has_key?(passport, "cid") && validate_passport(passport) ->
          true

        true ->
          false
      end
    end)
  end

  def validate_passport(passport) do
    Map.keys(passport)
    |> Enum.all?(fn key -> validate_passport_key(key, passport[key]) end)
  end

  def validate_passport_key(key, value)
  def validate_passport_key("cid", _), do: true

  def validate_passport_key("byr", value) do
    num_value = String.to_integer(value)
    num_value >= 1920 && num_value <= 2002 && String.length(value) == 4
  end

  def validate_passport_key("iyr", value) do
    num_value = String.to_integer(value)
    num_value >= 2010 && num_value <= 2020 && String.length(value) == 4
  end

  def validate_passport_key("eyr", value) do
    num_value = String.to_integer(value)
    num_value >= 2020 && num_value <= 2030 && String.length(value) == 4
  end

  def validate_passport_key("hgt", value) do
    map = Regex.named_captures(~r/^(?<num>[[:digit:]]+)(?<type>cm|in)$/, value)

    case map do
      nil ->
        false

      m ->
        case m["type"] do
          "cm" -> String.to_integer(m["num"]) >= 150 && String.to_integer(m["num"]) <= 193
          "in" -> String.to_integer(m["num"]) >= 59 && String.to_integer(m["num"]) <= 76
          _ -> false
        end
    end
  end

  def validate_passport_key("hcl", value), do: String.match?(value, ~r/^#[0-9a-f]{6}$/)

  def validate_passport_key("ecl", value) do
    case value do
      "amb" -> true
      "blu" -> true
      "brn" -> true
      "gry" -> true
      "grn" -> true
      "hzl" -> true
      "oth" -> true
      _ -> false
    end
  end

  def validate_passport_key("pid", value), do: String.match?(value, ~r/^[0-9]{9}$/)
  def validate_passport_key(_, _), do: false
end

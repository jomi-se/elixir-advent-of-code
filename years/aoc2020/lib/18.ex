defmodule MathParser do
  import NimbleParsec

  def get_expr_stream() do
    File.stream!("./input/18.txt")
    |> Stream.map(&String.replace(&1, ~r/[[:space:]]+/, "", global: true))
  end

  lparen = ascii_char([?(]) |> label("(")
  rparen = ascii_char([?)]) |> label(")")
  num_ = integer(min: 1) |> label("num")
  plus_ = ascii_char([?+]) |> label("+")
  minus_ = ascii_char([?-]) |> label("-")
  mult_ = ascii_char([?*]) |> label("*")
  div_ = ascii_char([?-]) |> label("-")

  oper_ = choice([plus_, minus_, mult_, div_]) |> label("oper")

  grouping = ignore(lparen) |> parsec(:expr) |> ignore(rparen)
  defcombinatorp(:factor, choice([num_, grouping]))

  defparsec(
    :expr,
    parsec(:factor)
    |> repeat(oper_ |> parsec(:factor))
    |> reduce(:fold_infixl)
  )

  defp fold_infixl(acc) do
    acc
    |> Enum.reverse()
    |> Enum.chunk_every(2)
    |> List.foldr([], fn
      [l], [] -> l
      [r, op], l -> {op, [l, r]}
    end)
  end

  defp unwrap({:ok, [acc], "", _, _, _}), do: acc
  defp unwrap({:ok, _, rest, _, _, _}), do: {:error, "could not parse" <> rest}

  def do_sum([a, b]) when is_integer(a) and is_integer(b), do: a + b
  def do_sum([a, b]) when is_integer(a), do: a + compute(b)
  def do_sum([a, b]) when is_integer(b), do: b + compute(a)
  def do_sum([a, b]), do:   compute(a) + compute(b)

  def do_mult([a, b]) when is_integer(a) and is_integer(b), do: a * b
  def do_mult([a, b]) when is_integer(a), do: a * compute(b)
  def do_mult([a, b]) when is_integer(b), do: b * compute(a)
  def do_mult([a, b]), do:   compute(a) * compute(b)


  def compute({ ?+, expr}) do
    do_sum(expr)
  end

  def compute({ ?*, expr}) do
    do_mult(expr)
  end

  def parse_and_compute(string) do
    string
    |> String.replace(~r/[[:space:]]+/, "", global: true)
    |> expr()
    |> unwrap()
    |> compute()
  end

  def part_1 do
    get_expr_stream()
    |> Enum.map(fn str ->
      str
      |> expr()
      |> unwrap()
      |> compute()
    end)
    |> Enum.sum()
  end
end

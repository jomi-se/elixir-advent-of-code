defmodule Flow do
  @block_order %{
    :hor_l => :plus,
    :plus => :angle,
    :angle => :ver_l,
    :ver_l => :block,
    :block => :hor_l
  }
  @block_map %{
    hor_l: [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    plus: [{0, 1}, {1, 2}, {1, 1}, {1, 0}, {2, 1}],
    angle: [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    ver_l: [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    block: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  }

  def read_file() do
    [str] =
      File.read!("./years/aoc2022/input/17.txt")
      |> String.split("\n", trim: true)

    String.graphemes(str)
  end

  def get_moves() do
    read_file()
  end

  def translate_move(">"), do: {1, 0}
  def translate_move("<"), do: {-1, 0}
  def translate_move(:down), do: {0, -1}

  def next_move(move, move_list)
  def next_move(move, []), do: next_move(move, get_moves())
  def next_move(">", move_list), do: {:down, move_list}
  def next_move("<", move_list), do: {:down, move_list}
  def next_move(:down, [next | rest_move_list]), do: {next, rest_move_list}

  def move_and_colide(piece, move, map) do
    {m_x, m_y} = translate_move(move)

    next_piece =
      piece
      |> Enum.map(fn {x, y} -> {x + m_x, y + m_y} end)

    did_colide =
      next_piece
      |> Enum.any?(fn {x, y} -> Map.has_key?(map, {x, y}) or x > 6 or x < 0 end)

    case did_colide do
      false ->
        {:cont, next_piece}

      true ->
        case move do
          :down ->
            new_map =
              piece
              |> Enum.reduce(map, fn {x, y}, acc_map ->
                Map.put(acc_map, {x, y}, true)
                |> Map.put(:max_y, max(acc_map.max_y, y))
              end)

            {:stop, new_map}

          _ ->
            {:cont, piece}
        end
    end
  end

  def get_next_piece(cur_piece_type, map) do
    next_piece_type = Map.get(@block_order, cur_piece_type)

    next_piece_coords =
      Map.get(@block_map, next_piece_type)
      |> Enum.map(fn {x, y} -> {x + 2, y + map.max_y + 4} end)

    %{type: next_piece_type, pos: next_piece_coords}
  end

  def step_game(_piece, _cur_move, _move_list, map, rock_count, limit) when rock_count == limit,
    do: map

  def step_game(piece, cur_move, move_list, map, rock_count, limit) do
    if Enum.random(1..100_000) <= 1 do
      IO.inspect(rock_count, label: "rock count")
    end

    {next_m, next_rest_moves} = next_move(cur_move, move_list)

    case move_and_colide(piece.pos, cur_move, map) do
      {:stop, next_map} ->
        step_game(
          get_next_piece(piece.type, next_map),
          next_m,
          next_rest_moves,
          next_map,
          rock_count + 1,
          limit
        )

      {:cont, next_piece_pos} ->
        step_game(
          %{piece | pos: next_piece_pos},
          next_m,
          next_rest_moves,
          map,
          rock_count,
          limit
        )
    end
  end

  def solve1(limit \\ 2022) do
    start_map =
      0..6
      |> Enum.reduce(
        %{max_y: 0},
        fn x, acc -> Map.put(acc, {x, 0}, true) end
      )

    [first_move | rest_moves] = get_moves()

    step_game(get_next_piece(:block, start_map), first_move, rest_moves, start_map, 0, limit)
    |> Map.get(:max_y)
  end
end

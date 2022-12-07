defmodule ImageBuilder do
  def parse_one(text) do
    [
      id_str
      | image
    ] =
      text
      |> String.split("\n", trim: true)

    id = Regex.named_captures(~r/^Tile (?<id>[0-9]+):$/, id_str)["id"] |> String.to_integer()

    parsed_image = %{
      :top => Enum.at(image, 0),
      :left =>
        Enum.reduce(image, "", fn string, acc ->
          [first | _] = string |> String.graphemes()
          acc <> first
        end),
      :right =>
        Enum.reduce(image, "", fn string, acc ->
          [first | _] = string |> String.graphemes() |> Enum.reverse()
          acc <> first
        end),
      :bot => image |> Enum.reverse() |> Enum.at(0),
      :raw => image,
      :angle => 0,
      :flip => false,
      :id => id
    }

    if String.length(parsed_image.top) != 10 or String.length(parsed_image.right) != 10 or
         String.length(parsed_image.bot) != 10 or String.length(parsed_image.left) != 10 do
      raise "DATA EERRROOORR  #{id_str}"
    end

    {id, parsed_image}
  end

  def read_file do
    images_raw =
      File.read!("./input/20.txt")
      |> String.split("\n\n", trim: true)

    images_map_by_id = for raw_img <- images_raw, into: %{}, do: parse_one(raw_img)
    images_map_by_id
  end

  def transform(map, "0") do
    _top = map.top
    _bot = map.bot
    _left = map.left
    _right = map.right

    map
  end

  def transform(map, "90") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    angle = map.angle

    %{
      map
      | :top => left |> String.reverse(),
        :right => top,
        :bot => right |> String.reverse(),
        :left => bot,
        :angle => rem(90 + angle, 360)
    }
  end

  def transform(map, "180") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    angle = map.angle

    %{
      map
      | :top => bot |> String.reverse(),
        :right => left |> String.reverse(),
        :bot => top |> String.reverse(),
        :left => right |> String.reverse(),
        :angle => rem(180 + angle, 360)
    }
  end

  def transform(map, "270") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    angle = map.angle

    %{
      map
      | :top => right,
        :right => bot |> String.reverse(),
        :bot => left,
        :left => top |> String.reverse(),
        :angle => rem(270 + angle, 360)
    }
  end

  def transform(map, "0F") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    flip = map.flip

    %{
      map
      | :top => top |> String.reverse(),
        :right => left,
        :bot => bot |> String.reverse(),
        :left => right,
        :flip => !flip
    }
  end

  def transform(map, "90F") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    flip = map.flip
    angle = map.angle

    %{
      map
      | :top => left,
        :right => bot,
        :bot => right,
        :left => top,
        :flip => !flip,
        :angle => rem(90 + angle, 360)
    }
  end

  def transform(map, "180F") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    flip = map.flip
    angle = map.angle

    %{
      map
      | :top => bot,
        :right => right |> String.reverse(),
        :bot => top,
        :left => left |> String.reverse(),
        :flip => !flip,
        :angle => rem(180 + angle, 360)
    }
  end

  def transform(map, "270F") do
    top = map.top
    bot = map.bot
    left = map.left
    right = map.right
    flip = map.flip
    angle = map.angle

    %{
      map
      | :top => right |> String.reverse(),
        :right => top |> String.reverse(),
        :bot => left |> String.reverse(),
        :left => bot |> String.reverse(),
        :angle => rem(270 + angle, 360),
        :flip => !flip
    }
  end

  @transformations_list ["0", "90", "180", "270", "0F", "90F", "180F", "270F"]
  # @edges [:top, :right, :bot, :left]
  @edges_pairs %{
    :top => :bot,
    :right => :left,
    :bot => :top,
    :left => :right
  }

  def get_transformation_for_map(map) do
    angle = map.angle
    flip = map.flip

    case flip do
      true -> "#{angle}F"
      false -> "#{angle}"
    end

    "#{angle}F"
  end

  def single_match_transform(origin_tile, target_tile, edge) do
    match =
      Enum.reduce(
        @transformations_list,
        [],
        fn trans, acc ->
          trans_tile = transform(target_tile, trans)
          target_edge = @edges_pairs[edge]

          case origin_tile[edge] == trans_tile[target_edge] do
            true -> [trans_tile | acc]
            false -> acc
          end
        end
      )

    match
  end

  def get_tiles_to_match({pos_x, pos_y}, map_by_pos) do
    top = {Map.get(map_by_pos, {pos_x, pos_y - 1}), :bot}
    bot = {Map.get(map_by_pos, {pos_x, pos_y + 1}), :top}
    right = {Map.get(map_by_pos, {pos_x + 1, pos_y}), :left}
    left = {Map.get(map_by_pos, {pos_x - 1, pos_y}), :right}

    [top, bot, right, left]
    |> Enum.filter(fn {tile, _} -> tile != nil end)
  end

  def get_common_transformations([first]), do: first

  def get_common_transformations([first, second]) do
    for f <- first, s <- second, f == s, into: [], do: f
  end

  def get_common_transformations([first, second, third]) do
    for f <- first, s <- second, t <- third, f == s and s == t, into: [], do: f
  end

  def get_common_transformations([first, second, third, fourth]) do
    for f <- first,
        s <- second,
        t <- third,
        o <- fourth,
        f == s and s == t and t == o,
        into: [],
        do: f
  end

  def get_next_position({pos_x, pos_y}, image_size) do
    cond do
      pos_x < image_size - 1 -> {pos_x + 1, pos_y}
      pos_y == image_size - 1 -> nil
      true -> {0, pos_y + 1}
    end
  end

  def do_recurse(_, image_size, map_by_ids, maps_by_pos)
      when map_size(maps_by_pos) < image_size * image_size and
             map_by_ids == %{},
      do: nil

  def do_recurse({pos_x, pos_y}, image_size, maps_by_id, maps_by_pos) do
    rest_tile_ids = Map.keys(maps_by_id)
    tiles_to_match = get_tiles_to_match({pos_x, pos_y}, maps_by_pos)

    Enum.find_value(
      rest_tile_ids,
      fn tile_id ->
        tile = Map.get(maps_by_id, tile_id)

        candidates =
          case tiles_to_match do
            [] ->
              all_orientations = Enum.map(@transformations_list, &transform(tile, &1))
              all_orientations

            _ ->
              matching_transforms =
                Enum.map(tiles_to_match, fn {origin_tile, edge} ->
                  single_match_transform(
                    origin_tile,
                    tile,
                    edge
                  )
                end)

              get_common_transformations(matching_transforms)
          end

        case candidates do
          [] ->
            nil

          _ ->
            candidates
            |> Enum.find_value(fn tile_cand ->
              new_map_ids = Map.delete(maps_by_id, tile_id)
              new_map_pos = Map.put(maps_by_pos, {pos_x, pos_y}, tile_cand)
              next_pos = get_next_position({pos_x, pos_y}, image_size)

              case next_pos do
                nil -> new_map_pos
                _ -> do_recurse(next_pos, image_size, new_map_ids, new_map_pos)
              end
            end)
        end
      end
    )
  end

  def part_1 do
    map = read_file()
    image_size = round(:math.sqrt(map_size(map)))
    ordered_image = do_recurse({0, 0}, image_size, map, %{})

    [{0, 0}, {0, image_size - 1}, {image_size - 1, 0}, {image_size - 1, image_size - 1}]
    |> Enum.map(&Map.get(ordered_image, &1).id)
    |> Enum.reduce(1, &(&1 * &2))
  end

  defp zip_lists_into_string([], []), do: []

  defp zip_lists_into_string([head1 | tail1], [head2 | tail2]),
    do: [head1 <> head2 | zip_lists_into_string(tail1, tail2)]

  def rotate_90(raw_image) do
    raw_image
    |> Enum.map(fn string -> String.graphemes(string) end)
    |> Enum.reduce(fn char_list, acc ->
      zip_lists_into_string(char_list, acc)
    end)
  end

  def rotate_180(raw_image) do
    raw_image
    |> Enum.map(fn string -> String.reverse(string) end)
    |> Enum.reverse()
  end

  def flip(raw_image) do
    raw_image
    |> Enum.map(&String.reverse(&1))
  end

  def transform_tile(tile) do
    angle = tile.angle
    flip = tile.flip

    case {angle, flip} do
      {0, false} -> tile
      {90, false} -> %{tile | :raw => tile.raw |> rotate_90()}
      {180, false} -> %{tile | :raw => tile.raw |> rotate_180()}
      {270, false} -> %{tile | :raw => tile.raw |> rotate_90() |> rotate_180}
      {0, true} -> %{tile | :raw => tile.raw |> flip()}
      {90, true} -> %{tile | :raw => tile.raw |> rotate_90() |> flip}
      {180, true} -> %{tile | :raw => tile.raw |> rotate_180() |> flip}
      {270, true} -> %{tile | :raw => tile.raw |> flip |> rotate_90()}
    end
  end

  def perform_actual_transformations(map_by_pos) do
    for pos <- Map.keys(map_by_pos),
        into: %{},
        do: {pos, transform_tile(Map.get(map_by_pos, pos))}
  end

  def trim_borders(raw_image) do
    raw_image
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> i != 0 && i != 9 end)
    |> Enum.map(fn {v, _} ->
      String.slice(v, 1..8)
    end)
  end

  def join_image(map_by_pos, image_size) do
    0..(image_size - 1)
    |> Enum.flat_map(fn pos_y ->
      0..(image_size - 1)
      |> Enum.map(fn pos_x -> Map.get(map_by_pos, {pos_x, pos_y}).raw |> trim_borders end)
      |> Enum.reduce(fn lines, acc -> zip_lists_into_string(acc, lines) end)
    end)
    |> rotate_180()
    |> flip()
    |> Enum.join("\n")
  end

  def print_image(map_by_pos, image_size) do
    join_image(map_by_pos, image_size)
    |> IO.puts()
  end

  def print_raw_tile(tile), do: tile.raw |> Enum.join("\n") |> IO.puts()

  def get_body_indexes(string) do
    string
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {val, _} -> val == "#" end)
    |> Enum.map(fn {_, index} -> index end)
  end

  def find_monster(raw_image, found_pos) do
    IO.puts(raw_image)
    IO.puts("\n")
    head = ~r/(..................)[#M](.)/
    upper = ~r/[#M](....)[#M]{2}(....)[#M]{2}(....)[#M]{3}/
    lower = ~r/(.)[#M](..)[#M](..)[#M](..)[#M](..)[#M](..)[#M](...)/
    monster_length = 20

    res =
      0..(96 - 2)
      |> Enum.find_value(fn pos_y ->
        0..96
        |> Enum.find_value(fn pos_x ->
          start_head = pos_x + pos_y * 97
          start_upper = pos_x + (pos_y + 1) * 97
          start_lower = pos_x + (pos_y + 2) * 97
          slice_head = String.slice(raw_image, start_head, monster_length)
          slice_upper = String.slice(raw_image, start_upper, monster_length)
          slice_lower = String.slice(raw_image, start_lower, monster_length)

          if String.match?(slice_head, head) and
               String.match?(slice_upper, upper) and
               String.match?(slice_lower, lower) and
               Map.get(found_pos, {pos_x, pos_y}) == nil do
            r_head = String.replace(slice_head, head, "\\1M\\2")
            r_upper = String.replace(slice_upper, upper, "M\\1MM\\2MM\\3MMM")
            r_lower = String.replace(slice_lower, lower, "\\1M\\2M\\3M\\4M\\5M\\6M\\7")

            {{start_head, r_head}, {start_upper, r_upper}, {start_lower, r_lower},
             Map.put(found_pos, {pos_x, pos_y}, true)}
          else
            nil
          end
        end)
      end)

    case res do
      {{start_head, r_head}, {start_upper, r_upper}, {start_lower, r_lower}, new_found_pos} ->
        new_image =
          String.slice(raw_image, 0..(start_head - 1)) <>
            r_head <>
            String.slice(raw_image, (start_head + monster_length)..(start_upper - 1)) <>
            r_upper <>
            String.slice(raw_image, (start_upper + monster_length)..(start_lower - 1)) <>
            r_lower <>
            String.slice(raw_image, (start_lower + monster_length)..-1)

        find_monster(new_image, new_found_pos)

      _ ->
        raw_image
    end
  end

  def part_2 do
    map = read_file()
    image_size = round(:math.sqrt(map_size(map)))
    ordered_image = do_recurse({0, 0}, image_size, map, %{})

    perform_actual_transformations(ordered_image)
    |> join_image(image_size)
    |> find_monster(%{})
    |> String.graphemes()
    |> Enum.count(fn char -> char == "#" end)
  end

end

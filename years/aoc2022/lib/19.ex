defmodule Geode do
  def read_file() do
    File.read!("./years/aoc2022/input/19.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      %{
        "ore_ore" => ore_ore,
        "clay_ore" => clay_ore,
        "obsidian_ore" => obsidian_ore,
        "obsidian_clay" => obsidian_clay,
        "geode_ore" => geode_ore,
        "geode_obsidian" => geode_obsidian,
        "id" => id
      } =
        Regex.named_captures(
          ~r/^Blueprint (?<id>\d+): Each ore robot costs (?<ore_ore>\d+) ore. Each clay robot costs (?<clay_ore>\d+) ore. Each obsidian robot costs (?<obsidian_ore>\d+) ore and (?<obsidian_clay>\d+) clay. Each geode robot costs (?<geode_ore>\d+) ore and (?<geode_obsidian>\d+) obsidian.$/,
          line
        )

      %{
        id: id |> String.to_integer(),
        ore_robot: %{:ore => ore_ore |> String.to_integer()},
        clay_robot: %{:ore => clay_ore |> String.to_integer()},
        obsidian_robot: %{
          :ore => obsidian_ore |> String.to_integer(),
          :clay => obsidian_clay |> String.to_integer()
        },
        geode_robot: %{
          :ore => geode_ore |> String.to_integer(),
          :obsidian => geode_obsidian |> String.to_integer()
        }
      }
    end)
  end

  def robot_get_materials(robot_inv, materials_inv) do
    %{
      ore: materials_inv.ore + robot_inv.ore_robot,
      clay: materials_inv.clay + robot_inv.clay_robot,
      obsidian: materials_inv.obsidian + robot_inv.obsidian_robot,
      geode: materials_inv.geode + robot_inv.geode_robot
    }
  end

  def get_possible_next_robot(materials_inv, blueprint, cur_min) do
    # [
    #   :geode_robot,
    #   :obsidian_robot,
    #   :clay_robot,
    #   :ore_robot
    # ]
    order_robots =
      [
        :geode_robot,
        :obsidian_robot
      ] ++
        if(cur_min <= blueprint.obsidian_robot.clay * 3,
          do: [:clay_robot],
          else: []
        ) ++
        if(cur_min <= 15, do: [:ore_robot], else: [])

    next_possible_robots =
      order_robots
      |> Enum.map(fn type -> {type, Map.fetch!(blueprint, type)} end)
      |> Enum.filter(fn {_type, requirements_map} ->
        requirements_map
        |> Map.to_list()
        |> Enum.all?(fn {ore_type, req_qty} ->
          Map.fetch!(materials_inv, ore_type) >= req_qty
        end)
      end)
      |> Enum.map(fn {type, requirements_map} ->
        new_materials_inv =
          requirements_map
          |> Map.to_list()
          |> Enum.reduce(materials_inv, fn {ore_type, req_qty}, acc_map ->
            Map.update!(acc_map, ore_type, fn v -> v - req_qty end)
          end)

        {type, new_materials_inv}
      end)

    next_possible_robots ++ [{nil, materials_inv}]
  end

  def discount_materials(robot_type, materials_inv, blueprint) do
    Map.fetch!(blueprint, robot_type)
    |> Map.to_list()
    |> Enum.reduce(materials_inv, fn {ore_type, req_qty}, acc_map ->
      Map.update!(acc_map, ore_type, fn v -> v - req_qty end)
    end)
  end

  def get_possible_next_robot_v2(robot_inv, materials_inv, blueprint) do
    order_robots = [
      :geode_robot,
      :obsidian_robot,
      :clay_robot,
      :ore_robot
    ]

    next_robots =
      order_robots
      |> Enum.reduce([], fn
        :geode_robot, acc ->
          cond do
            materials_inv.obsidian >= blueprint.geode_robot.obsidian and
                materials_inv.ore >= blueprint.geode_robot.ore ->
              [{:geode_robot, discount_materials(:geode_robot, materials_inv, blueprint)} | acc]

            materials_inv.obsidian >= blueprint.geode_robot.obsidian - 1 ->
              [{nil, materials_inv} | acc]

            true ->
              acc
          end

        :obsidian_robot, acc ->
          cond do
            robot_inv.obsidian_robot >= blueprint.geode_robot.obsidian ->
              acc

            materials_inv.clay >= blueprint.obsidian_robot.clay and
                materials_inv.ore >= blueprint.obsidian_robot.ore ->
              [
                {:obsidian_robot, discount_materials(:obsidian_robot, materials_inv, blueprint)},
                {nil, materials_inv}
                | acc
              ]

            materials_inv.clay >= blueprint.obsidian_robot.clay - 1 and
                Enum.find(acc, fn {type, _} -> type == nil end) ==
                  nil ->
              [{nil, materials_inv} | acc]

            true ->
              acc
          end

        :clay_robot, acc ->
          cond do
            Enum.find(acc, fn {type, _} -> type == :obsidian_robot end) != nil ->
              acc

            robot_inv.clay_robot >= blueprint.obsidian_robot.clay ->
              acc

            materials_inv.ore >= blueprint.clay_robot.ore ->
              [
                {:clay_robot, discount_materials(:clay_robot, materials_inv, blueprint)}
                | acc
              ]

            true ->
              acc
          end

        :ore_robot, acc ->
          max_ore_req =
            Enum.reduce(order_robots, 0, fn type, acc_max ->
              ore_req = Map.fetch!(blueprint, type) |> Map.get(:ore)
              max(ore_req, acc_max)
            end)

          cond do
            Enum.find(acc, fn {type, _} -> type == :obsidian_robot end) != nil ->
              acc

            robot_inv.ore_robot >= max_ore_req ->
              acc

            materials_inv.ore >= blueprint.ore_robot.ore ->
              [
                {:ore_robot, discount_materials(:ore_robot, materials_inv, blueprint)}
                | acc
              ]

            true ->
              acc
          end
      end)
      |> Enum.reverse()

    case next_robots do
      [] -> [{nil, materials_inv}]
      [{:ore_robot, mat_inv}] -> [{:ore_robot, mat_inv}, {nil, materials_inv}]
      [{:clay_robot, mat_inv}] -> [{:clay_robot, mat_inv}, {nil, materials_inv}]
      other -> other
    end
  end

  def step_robots_with_blueprint(
        _robot_inv,
        materials_inv,
        _blueprint,
        cur_min,
        limit,
        acc_max_geodes
      )
      when limit == cur_min,
      do: max(materials_inv.geode, acc_max_geodes)

  def step_robots_with_blueprint(
        robot_inv,
        materials_inv,
        blueprint,
        cur_min,
        limit,
        acc_max_geodes
      ) do
    # IO.inspect(binding(), label: cur_min)

    # if Enum.random(1..100_000) <= 1 do
    #   IO.inspect(acc_max_geodes, label: "max geodes")
    # end

    next_robots = get_possible_next_robot_v2(robot_inv, materials_inv, blueprint)
    # |> IO.inspect(label: "next robots")

    Enum.reduce(next_robots, acc_max_geodes, fn
      {nil, materials_inv}, acc ->
        materials_inv_after_robot = robot_get_materials(robot_inv, materials_inv)

        step_robots_with_blueprint(
          robot_inv,
          materials_inv_after_robot,
          blueprint,
          cur_min + 1,
          limit,
          acc
        )

      {robot, next_materials_inv}, acc ->
        next_robot_inv = Map.update!(robot_inv, robot, fn v -> v + 1 end)

        materials_inv_after_robot = robot_get_materials(robot_inv, next_materials_inv)

        step_robots_with_blueprint(
          next_robot_inv,
          materials_inv_after_robot,
          blueprint,
          cur_min + 1,
          limit,
          acc
        )
    end)
  end

  def solve1 do
    blueprints_parsed = read_file()

    robot_inv = %{
      ore_robot: 1,
      clay_robot: 0,
      obsidian_robot: 0,
      geode_robot: 0
    }

    materials_inv = %{
      ore: 0,
      clay: 0,
      obsidian: 0,
      geode: 0
    }

    Enum.map(blueprints_parsed, fn blueprint ->
      IO.inspect(blueprint.id)
      {blueprint.id, step_robots_with_blueprint(robot_inv, materials_inv, blueprint, 0, 24, 0)}
    end)
    |> IO.inspect()
    |> Enum.map(fn {id, val} -> id * val end)
    |> Enum.sum()
  end
end

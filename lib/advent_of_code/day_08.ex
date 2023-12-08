defmodule AdventOfCode.Day08 do
  def part1(input) do
    input
    |> parse_input()
    |> follow_map("AAA", "ZZZ")
  end

  def part2(input) do
    map = parse_input(input)
    starting_nodes = get_starting_nodes(map)
    goal_nodes = get_goal_nodes(map)
    counts = for node <- starting_nodes, do: follow_map(map, node, goal_nodes)
    lcm(counts)
  end

  defp lcm([a, b]), do: lcm(a, b)
  defp lcm([a, b | rest]), do: lcm([lcm(a, b) | rest])

  defp lcm(a, b) do
    div(a * b, gcd(a, b))
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp get_starting_nodes({_, nodes}) do
    nodes
    |> Map.keys()
    |> Enum.filter(fn node -> String.ends_with?(node, "A") end)
  end

  defp get_goal_nodes({_, nodes}) do
    nodes
    |> Map.keys()
    |> Enum.filter(fn node -> String.ends_with?(node, "Z") end)
  end

  defp follow_map(map, start, goal) do
    follow_map(map, start, goal, 0)
  end

  defp follow_map(_, goal, goal, steps), do: steps

  defp follow_map({instructions, nodes} = map, location, goal, steps) do
    if is_list(goal) and location in goal do
      steps
    else
      instruction = elem(instructions, rem(steps, tuple_size(instructions)))
      next = nodes |> Map.get(location) |> elem(instruction)
      follow_map(map, next, goal, steps + 1)
    end
  end

  defp parse_input(input) do
    [instructions | nodes] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)

    {parse_instructions(instructions), parse_nodes(nodes)}
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split("", trim: true)
    |> Enum.map(fn
      "L" -> 0
      "R" -> 1
    end)
    |> List.to_tuple()
  end

  defp parse_nodes(nodes) do
    nodes
    |> Enum.map(&parse_node/1)
    |> Map.new()
  end

  defp parse_node(node) do
    [_, node, left, right] = Regex.run(~r/^(\S+)\s*=\s*\((\S+),\s*(\S+)\)$/, node)
    {node, {left, right}}
  end
end

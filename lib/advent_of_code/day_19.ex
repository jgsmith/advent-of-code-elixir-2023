defmodule AdventOfCode.Day19 do
  def part1(input) do
    {workflows, parts} = parse_input(input)

    parts
    |> sort_parts(workflows)
    |> Map.get("A")
    |> Enum.map(fn part ->
      part |> Map.values() |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {workflows, _parts} = parse_input(input)

    workflows
    |> process_workflows([{%{x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000}, "in"}])
    |> Enum.map(fn part ->
      part |> Map.values() |> Enum.map(&Range.size/1) |> Enum.product()
    end)
    |> Enum.sum()
  end

  defp sort_parts(parts, workflows) do
    parts
    |> Enum.group_by(fn part -> sort_part(part, workflows, "in") end)
  end

  defp sort_part(_, _, workflow) when workflow in ["A", "R"], do: workflow

  defp sort_part(part, workflows, workflow) do
    instructions = Map.get(workflows, workflow)
    sort_part(part, workflows, next_workflow(part, instructions))
  end

  defp next_workflow(part, [{field, op, value, dest} | instructions]) do
    go? =
      case op do
        :lt -> Map.get(part, field) < value
        :gt -> Map.get(part, field) > value
      end

    if go? do
      dest
    else
      next_workflow(part, instructions)
    end
  end

  defp next_workflow(_part, [dest | _]) when is_binary(dest), do: dest

  defp process_workflows(workflows, parts, accepted \\ [])
  defp process_workflows(_, [], accepted), do: accepted

  defp process_workflows(workflows, [{part, workflow} | parts], accepted) do
    reduced_parts = process_workflow(workflows, part, workflow)

    accepted_parts =
      reduced_parts
      |> Enum.filter(fn {_, next_workflow} -> next_workflow == "A" end)
      |> Enum.map(fn {part, _} -> part end)

    unfinished_parts =
      reduced_parts |> Enum.filter(fn {_, next_workflow} -> next_workflow not in ["A", "R"] end)

    process_workflows(workflows, unfinished_parts ++ parts, accepted_parts ++ accepted)
  end

  defp process_workflow(workflows, part, workflow) do
    instructions = Map.get(workflows, workflow)

    workflows
    |> Map.get(workflow)
    |> Enum.reduce({part, []}, fn instruction, {part, acc} ->
      {split, remainder} = process_instruction(part, instruction)
      {remainder, [split | acc]}
    end)
    |> elem(1)
  end

  # defp process_instruction(nil, _), do: nil
  defp process_instruction(part, {field, op, value, dest}) do
    # we're splitting a range into two parts: the range that matches and the range that doesn't
    range = Map.get(part, field)
    # the match goes to the destination
    # the remainder goes to the next instruction
    if op == :lt do
      {left, right} = Range.split(range, value - range.first)
      {{Map.put(part, field, left), dest}, Map.put(part, field, right)}
    else
      {left, right} = Range.split(range, value - range.first + 1)

      {{Map.put(part, field, right), dest}, Map.put(part, field, left)}
    end
  end

  defp process_instruction(part, instruction) when is_binary(instruction) do
    {{part, instruction}, nil}
  end

  defp parse_input(input) do
    [workflow_input, parts_input] = String.split(input, "\n\n", parts: 2)

    workflows =
      workflow_input
      |> String.split("\n")
      |> Enum.map(&parse_workflow/1)
      |> Map.new()

    parts =
      parts_input
      |> String.split("\n")
      |> Enum.map(&parse_part/1)

    {workflows, parts}
  end

  defp parse_workflow(line) do
    [_, rule_name, instruction_source] = Regex.run(~r/([a-z]+)\{(.*)\}\s*$/, line)

    instructions =
      instruction_source |> String.split(",", trim: true) |> Enum.map(&parse_instruction/1)

    {rule_name, instructions}
  end

  defp parse_instruction(instruction) do
    if Regex.match?(~r/^[a-zA-Z]+$/, instruction) do
      instruction
    else
      # field op value dest
      [_, field, op, value, dest] = Regex.run(~r/^([xmas])([<=>])(\d+):([a-zA-Z]+)$/, instruction)

      op =
        case op do
          "<" -> :lt
          ">" -> :gt
        end

      {String.to_atom(field), op, String.to_integer(value), dest}
    end
  end

  defp parse_part(""), do: %{x: 0, m: 0, a: 0, s: 0}

  defp parse_part(line) do
    [internals] = Regex.run(~r/^\{(.*)\}\s*$/, line, capture: :all_but_first)

    internals
    |> String.split(",", trim: true)
    |> Enum.map(fn bit ->
      [field, value] = String.split(bit, "=", trim: true)
      {String.to_atom(field), String.to_integer(value)}
    end)
    |> Map.new()
  end
end

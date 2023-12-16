defmodule AdventOfCode.Day16 do
  @type position :: {integer, integer}
  @type contraption :: {map(), position}
  @type direction :: :up | :down | :left | :right
  @type visitation :: %{position => [direction]}
  @type state :: {position, direction}

  def part1(input) do
    input
    |> parse_input()
    |> shoot_beam({0, 0}, :right)
    |> map_size()
  end

  def part2(input) do
    input
    |> parse_input()
    |> walk_perimeter()
    |> Enum.map(&map_size/1)
    |> Enum.max()
  end

  @spec walk_perimeter(contraption()) :: [visitation()]
  defp walk_perimeter({_, {max_col, max_row}} = contraption) do
    [
      shoot_beam(contraption, {0, 0}, :right),
      shoot_beam(contraption, {0, 0}, :down),
      shoot_beam(contraption, {max_col, 0}, :left),
      shoot_beam(contraption, {max_col, 0}, :down),
      shoot_beam(contraption, {0, max_row}, :right),
      shoot_beam(contraption, {0, max_row}, :up),
      shoot_beam(contraption, {max_col, max_row}, :left),
      shoot_beam(contraption, {max_col, max_row}, :up)
    ] ++
      for(col <- 1..(max_col - 1), do: shoot_beam(contraption, {col, 0}, :down)) ++
      for(col <- 1..(max_col - 1), do: shoot_beam(contraption, {col, max_row}, :up)) ++
      for(row <- 1..(max_row - 1), do: shoot_beam(contraption, {0, row}, :right)) ++
      for row <- 1..(max_row - 1), do: shoot_beam(contraption, {max_col, row}, :left)
  end

  @spec shoot_beam(contraption, position, direction) :: visitation()
  defp shoot_beam(contraption, position, direction) do
    follow_beam([{position, direction}], contraption, %{})
  end

  @spec follow_beam([state], contraption, visitation) :: visitation
  defp follow_beam([], _, visited), do: visited

  defp follow_beam([{position, velocity} = state | other_states], contraption, visited) do
    # display_contraption(contraption, visited)

    state
    |> next_states(contraption)
    |> Enum.reject(fn {p, v} -> v in Map.get(visited, p, []) end)
    |> Kernel.++(other_states)
    |> follow_beam(
      contraption,
      Map.update(visited, position, [velocity], &[velocity | &1])
    )
  end

  @spec next_states(state, contraption) :: [state]
  defp next_states(state, contraption) do
    state
    |> get_operation(contraption)
    |> Enum.map(fn op -> change_state(contraption, state, op) end)
    |> Enum.reject(&is_nil/1)
  end

  @spec change_state(contraption, state, direction) :: state | nil
  defp change_state({_, {max_col, max_row}}, {{col, row}, _}, velocity) do
    {new_col, new_row} =
      case velocity do
        :up -> {col, row - 1}
        :down -> {col, row + 1}
        :left -> {col - 1, row}
        :right -> {col + 1, row}
      end

    if new_col > max_col or new_row > max_row or new_col < 0 or new_row < 0 do
      nil
    else
      {{new_col, new_row}, velocity}
    end
  end

  @spec get_operation(position, contraption) :: [direction]
  defp get_operation({position, velocity}, {map, _}) do
    case {velocity, Map.get(map, position)} do
      {v, "-"} when v in [:up, :down] -> [:left, :right]
      {v, "|"} when v in [:left, :right] -> [:up, :down]
      {:up, "/"} -> [:right]
      {:down, "/"} -> [:left]
      {:left, "/"} -> [:down]
      {:right, "/"} -> [:up]
      {:up, "\\"} -> [:left]
      {:down, "\\"} -> [:right]
      {:left, "\\"} -> [:up]
      {:right, "\\"} -> [:down]
      _ -> [velocity]
    end
  end

  @spec parse_input(String.t()) :: contraption
  defp parse_input(input) do
    lines =
      input
      |> String.trim()
      |> String.split("\n", trim: true)

    max_row = Enum.count(lines) - 1
    max_col = String.length(hd(lines)) - 1

    {lines
     |> Enum.with_index()
     |> Enum.flat_map(&parse_line/1)
     |> Map.new(), {max_col, max_row}}
  end

  @spec parse_line({String.t(), integer}) :: [{position, String.t()}]
  defp parse_line({line, row}) do
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {cell, col} ->
      if cell == ".", do: [], else: [{{col, row}, cell}]
    end)
  end
end

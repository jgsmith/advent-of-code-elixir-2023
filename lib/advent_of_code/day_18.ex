defmodule AdventOfCode.Day18 do
  def part1(input) do
    input
    |> parse_input()
    |> dig_trench()
    |> dig_interior()
    |> map_size()
  end

  def part2(input) do
    input
    |> parse_input2()
    |> find_vertices()
    |> area_of_polygon()
  end

  defp find_vertices(instructions, turtle \\ {0, 0}, vertices \\ [{0, 0}])
  defp find_vertices([], _, vertices), do: vertices

  defp find_vertices([{direction, distance} | instructions], {x, y}, vertices) do
    new_turtle =
      case direction do
        :up -> {x, y + distance}
        :down -> {x, y - distance}
        :right -> {x + distance, y}
        :left -> {x - distance, y}
      end

    find_vertices(instructions, new_turtle, [new_turtle | vertices])
  end

  # this counts the interior using the determinate method and adds the boundary
  # then adds 1 because otherwise it's off by 1
  defp area_of_polygon(vertices) do
    a =
      vertices
      |> Enum.zip(tl(vertices))
      |> Enum.map(fn {{x1, y1}, {x2, y2}} -> x1 * y2 - x2 * y1 + abs(x1 - x2) + abs(y1 - y2) end)
      |> Enum.sum()

    div(a, 2) + 1
  end

  defp dig_interior(trench) do
    # this uses the winding number idea to determine where we dig out the interior
    # two special cases: top, bottom - so we ignore the most extreme vertical lines
    {min_y, max_y} = trench |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()
    {min_x, max_x} = trench |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()

    (min_y + 1)..(max_y - 1)
    |> Enum.reduce(trench, fn y, filled_trench ->
      min_x..max_x
      |> Enum.reduce({filled_trench, 0, nil}, fn x, {filled_trench, count, prev} ->
        {new_count, new_prev} =
          case {prev, boundary_type(trench, {x, y})} do
            {prev, nil} -> {count, prev}
            {:up_right, :down_left} -> {count + 1, nil}
            {:down_right, :up_left} -> {count + 1, nil}
            {:up_right, :up_left} -> {count, nil}
            {:down_right, :down_left} -> {count, nil}
            {_, :up_right} -> {count, :up_right}
            {_, :down_right} -> {count, :down_right}
            {_, :up_left} -> {count, nil}
            {_, :down_left} -> {count, nil}
            {_, :left_right} -> {count, prev}
            {_, :up_down} -> {count + 1, nil}
          end

        if rem(new_count, 2) == 1 do
          # we're inside!
          {Map.put(filled_trench, {x, y}, 1), new_count, new_prev}
        else
          {filled_trench, new_count, new_prev}
        end
      end)
      |> elem(0)
    end)
  end

  defp boundary_type(trench, {x, y}) do
    case {
      not is_nil(Map.get(trench, {x, y})),
      not is_nil(Map.get(trench, {x, y + 1})),
      not is_nil(Map.get(trench, {x, y - 1})),
      not is_nil(Map.get(trench, {x + 1, y})),
      not is_nil(Map.get(trench, {x - 1, y}))
    } do
      # if the location isn't on the boundary, then no boundary
      {false, _, _, _, _} -> nil
      # if the location is isolated, no boundary
      {true, false, false, false, false} -> nil
      {true, false, false, false, true} -> :left
      {true, false, false, true, false} -> :right
      {true, false, false, true, true} -> :left_right
      {true, false, true, false, false} -> :down
      {true, false, true, false, true} -> :down_left
      {true, false, true, true, false} -> :down_right
      {true, true, false, false, false} -> :up
      {true, true, false, false, true} -> :up_left
      {true, true, false, true, false} -> :up_right
      {true, true, true, false, false} -> :up_down
    end
  end

  defp dig_trench(instructions, ocation \\ {0, 0}, trench \\ %{})
  defp dig_trench([], _, trench), do: trench

  defp dig_trench([instruction | instructions], location, trench) do
    {direction, distance, _} = instruction
    {new_location, new_trench} = dig(trench, location, direction, distance)
    dig_trench(instructions, new_location, new_trench)
  end

  defp dig(trench, location, :up, distance) do
    1..distance
    |> Enum.reduce({location, trench}, fn _i, {{x, y}, trench} ->
      new_location = {x, y + 1}
      new_trench = Map.put(trench, new_location, 1)
      {new_location, new_trench}
    end)
  end

  defp dig(trench, location, :down, distance) do
    1..distance
    |> Enum.reduce({location, trench}, fn _i, {{x, y}, trench} ->
      new_location = {x, y - 1}
      new_trench = Map.put(trench, new_location, 1)
      {new_location, new_trench}
    end)
  end

  defp dig(trench, location, :right, distance) do
    1..distance
    |> Enum.reduce({location, trench}, fn _i, {{x, y}, trench} ->
      new_location = {x + 1, y}
      new_trench = Map.put(trench, new_location, 1)
      {new_location, new_trench}
    end)
  end

  defp dig(trench, location, :left, distance) do
    1..distance
    |> Enum.reduce({location, trench}, fn _i, {{x, y}, trench} ->
      new_location = {x - 1, y}
      new_trench = Map.put(trench, new_location, 1)
      {new_location, new_trench}
    end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [_, direction, length, color] =
      Regex.run(~r/^(\S)\s+(\d+)\s+\(#([0-9a-f]{6})\)$/, String.trim(line))

    {direction(direction), String.to_integer(length), color}
  end

  defp direction("U"), do: :up
  defp direction("D"), do: :down
  defp direction("L"), do: :left
  defp direction("R"), do: :right
  defp direction("3"), do: :up
  defp direction("1"), do: :down
  defp direction("2"), do: :left
  defp direction("0"), do: :right

  defp parse_input2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line2/1)
  end

  defp parse_line2(line) do
    [_, length, direction] =
      Regex.run(~r/\(#([0-9a-f]{5})([0-3])\)$/, String.trim(line))

    {direction(direction), String.to_integer(length, 16)}
  end
end

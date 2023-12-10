defmodule AdventOfCode.Day10 do
  # tuple of strings
  @type pipe_map :: tuple()
  # {row, col}
  @type location :: {integer(), integer()}
  # map of locations to steps
  @type path :: %{location() => integer()}

  def part1(input) do
    map = parse_input(input)
    start = locate_animal(map)

    map
    |> walk_pipes(start)
    |> get_max_steps()
  end

  # This might be a bit confusing, but "x" is the "row" and "y" is the "column"
  # the x/y axis is reflected around the line x=y
  def part2(input) do
    map = parse_input(input)
    start = locate_animal(map)
    map = map_put(map, start, start_pipe(map, start))

    loop =
      map
      |> walk_pipes(start)
      |> Map.keys()

    for x <- 0..(tuple_size(map) - 1) do
      for y <- 0..(String.length(elem(map, x)) - 1) do
        rem(winding_number(map, loop, {x, y}), 2)
      end
    end
    |> List.flatten()
    |> Enum.sum()
  end

  @spec winding_number(pipe_map(), [location()], location()) :: integer()
  defp winding_number(map, loop, {row, col} = location) do
    if location in loop do
      # points on the loop aren't in the loop
      0
    else
      boundary = Enum.filter(loop, fn {x, y} -> x == row and y < col end)
      #  count transitions between "||", "|L", "L-", "-J", "J|", "|F", "F-", "-7", ...
      boundary
      |> Enum.sort()
      |> Enum.reduce({0, nil}, fn pipe_loc, {count, prev} ->
        pipe = map_at(map, pipe_loc)

        case {prev, pipe} do
          {"L", "7"} -> {count + 1, nil}
          {"F", "J"} -> {count + 1, nil}
          {"L", "J"} -> {count, nil}
          {"F", "7"} -> {count, nil}
          {_, "L"} -> {count, "L"}
          {_, "F"} -> {count, "F"}
          {_, "J"} -> {count, nil}
          {_, "7"} -> {count, nil}
          {_, "-"} -> {count, prev}
          {_, "|"} -> {count + 1, nil}
        end
      end)
      |> elem(0)
    end
  end

  @spec get_max_steps(path()) :: integer()
  defp get_max_steps(journey) do
    journey
    |> Map.values()
    |> Enum.max()
  end

  @spec walk_pipes(pipe_map(), location() | [location()]) :: path()
  defp walk_pipes(map, locations, steps \\ 0, acc \\ %{})

  defp walk_pipes(_, [], _, acc), do: acc

  defp walk_pipes(map, locations, steps, acc) when is_list(locations) do
    next_locations =
      locations
      |> Enum.flat_map(&neighbors(map, &1))
      |> Enum.reject(&Map.has_key?(acc, &1))

    next_acc =
      next_locations
      |> Enum.reduce(acc, fn location, acc ->
        Map.put(acc, location, steps + 1)
      end)

    walk_pipes(map, next_locations, steps + 1, next_acc)
  end

  defp walk_pipes(map, location, steps, acc) do
    walk_pipes(map, [location], steps, acc)
  end

  @spec locate_animal(pipe_map()) :: location()
  defp locate_animal(map) do
    {line, row} =
      map
      |> Tuple.to_list()
      |> Enum.with_index()
      |> Enum.find(fn {line, _} -> String.contains?(line, "S") end)

    {row, String.split(line, "S") |> hd |> String.length()}
  end

  @spec neighbors(pipe_map(), location()) :: [location()]
  defp neighbors(map, {row, col}) do
    map
    |> map_at({row, col})
    |> case do
      "|" ->
        [{row - 1, col}, {row + 1, col}]

      "-" ->
        [{row, col - 1}, {row, col + 1}]

      "." ->
        []

      "L" ->
        [{row - 1, col}, {row, col + 1}]

      "J" ->
        [{row - 1, col}, {row, col - 1}]

      "7" ->
        [{row + 1, col}, {row, col - 1}]

      "F" ->
        [{row + 1, col}, {row, col + 1}]

      "S" ->
        # we have to look at all of the characters around S
        # if they would connect to S, then they are neighbors
        [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
        |> Enum.filter(fn position ->
          {row, col} in neighbors(map, position)
        end)
    end
  end

  @spec start_pipe(pipe_map(), location()) :: String.t()
  defp start_pipe(map, {row, col}) do
    up = {row - 1, col}
    down = {row + 1, col}
    left = {row, col - 1}
    right = {row, col + 1}

    [left, down, up, right]
    |> Enum.filter(fn position ->
      {row, col} in neighbors(map, position)
    end)
    |> case do
      [^left, ^down] -> "7"
      [^left, ^up] -> "J"
      [^left, ^right] -> "-"
      [^down, ^up] -> "|"
      [^down, ^right] -> "F"
      [^up, ^right] -> "L"
    end
  end

  @spec map_put(pipe_map(), location(), String.t()) :: pipe_map()
  defp map_put(map, {row, col}, symbol) do
    line = elem(map, row)

    map
    |> Tuple.to_list()
    |> List.replace_at(
      row,
      String.slice(line, 0, col) <>
        symbol <> String.slice(line, col + 1, String.length(line) - col - 1)
    )
    |> List.to_tuple()
  end

  @spec map_at(pipe_map(), location()) :: String.t()
  defp map_at(map, {row, col}) when row >= 0 and row < tuple_size(map) do
    map
    |> elem(row)
    |> String.at(col)
  end

  defp map_at(_, _), do: "."

  @spec parse_input(String.t()) :: pipe_map()
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> List.to_tuple()
  end
end

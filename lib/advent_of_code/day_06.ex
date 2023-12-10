defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&count_of_ways_to_win/1)
    |> Enum.product()
  end

  def part2(input) do
    input
    |> parse_part2_input()
    |> Enum.map(&count_of_ways_to_win/1)
    |> Enum.product()
  end

  defp count_of_ways_to_win(race) do
    {lower, upper} = winning_bounds(race)
    upper - lower + 1
  end

  defp winning_bounds({time, distance}) do
    # hold_time * (time - hold_time) - distance == 0
    # - hold_time^2 + time * hold_time - distance == 0
    lower_bound = ceil((time - :math.sqrt(time * time - 4 * distance)) / 2)

    lower_bound =
      if lower_bound * (time - lower_bound) - distance <= 0,
        do: lower_bound + 1,
        else: lower_bound

    upper_bound = floor((time + :math.sqrt(time * time - 4 * distance)) / 2)

    upper_bound =
      if upper_bound * (time - upper_bound) - distance <= 0,
        do: upper_bound - 1,
        else: upper_bound

    {lower_bound, upper_bound}
  end

  @spec parse_input(String.t()) :: [{integer(), integer()}]
  defp parse_input(input) do
    ["Time:" <> times, "Distance:" <> distances] = String.split(input, "\n", trim: true)

    times =
      times |> String.trim() |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

    distances =
      distances
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    Enum.zip(times, distances)
  end

  defp parse_part2_input(input) do
    ["Time:" <> times, "Distance:" <> distances] = String.split(input, "\n", trim: true)

    time =
      times
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.join("")
      |> String.to_integer()

    distance =
      distances
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.join("")
      |> String.to_integer()

    [{time, distance}]
  end
end

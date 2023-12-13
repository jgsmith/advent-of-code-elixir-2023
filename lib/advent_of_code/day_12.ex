defmodule AdventOfCode.Day12 do
  use Memoize

  def part1(input) do
    Application.ensure_all_started(:memoize)

    input
    |> parse_input()
    |> count_permutations()
  end

  def part2(input) do
    Application.ensure_all_started(:memoize)

    input
    |> parse_input()
    |> unfold()
    |> count_permutations()
  end

  defp unfold(rows) when is_list(rows) do
    rows
    |> Enum.map(&unfold/1)
  end

  defp unfold({symbols, runs}) do
    {List.flatten([symbols, "?", symbols, "?", symbols, "?", symbols, "?", symbols]),
     List.flatten([runs, runs, runs, runs, runs])}
  end

  defp count_permutations(rows) when is_list(rows) do
    rows
    |> Enum.map(&count_permutations/1)
    |> Enum.sum()
  end

  defp count_permutations({symbols, runs}) do
    count_permutations(symbols, runs, 0)
  end

  def count_permutations(symbols, [], _) do
    if "#" in symbols, do: 0, else: 1
  end

  def count_permutations([], [current_run], seen) do
    if current_run == seen, do: 1, else: 0
  end

  # there are no symbols but runs remaining to be seen
  def count_permutations([], [_, _ | _], _), do: 0

  defmemo count_permutations([symbol | symbols], [current_run | _] = runs, seen) do
    case symbol do
      "?" ->
        cond do
          seen == 0 ->
            count_permutations(symbols, runs, seen + 1) +
              count_permutations(symbols, runs, 0)

          current_run > seen ->
            # assume "#" for this one since we need it
            count_permutations(symbols, runs, seen + 1)

          current_run == seen ->
            # assume "." for this one since we need it
            count_permutations(symbols, tl(runs), 0)
        end

      "#" ->
        if seen < current_run do
          count_permutations(symbols, runs, seen + 1)
        else
          # uh oh - we can't have this!
          0
        end

      "." ->
        cond do
          seen == 0 ->
            count_permutations(symbols, runs, 0)

          current_run == seen ->
            count_permutations(symbols, tl(runs), 0)

          seen < current_run ->
            # uh oh - we can't have this!
            0
        end
    end
  end

  defp parse_line(line) do
    [symbols, numbers] = String.split(line, " ", trim: true)
    damaged_runs = numbers |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
    {String.split(symbols, "", trim: true), damaged_runs}
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_line/1)
  end
end

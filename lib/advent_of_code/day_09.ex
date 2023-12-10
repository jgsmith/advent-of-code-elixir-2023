defmodule AdventOfCode.Day09 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&differences/1)
    |> Enum.map(&advance_differences/1)
    |> Enum.map(fn differences ->
      # we want the first of the last line
      differences
      |> List.last()
      |> hd
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&differences/1)
    |> Enum.map(fn differences ->
      Enum.map(differences, &Enum.reverse/1)
    end)
    |> Enum.map(&prevance_differences/1)
    |> Enum.map(fn differences ->
      # we want the first of the last line
      differences
      |> List.last()
      |> hd
    end)
    |> Enum.sum()
  end

  defp advance_differences(differences, delta \\ 0, acc \\ [])
  defp advance_differences([], _, acc), do: Enum.reverse(acc)

  defp advance_differences([head | tail], delta, acc) do
    next_delta = hd(head) + delta
    advance_differences(tail, next_delta, [[next_delta | head] | acc])
  end

  defp prevance_differences(differences, delta \\ 0, acc \\ [])
  defp prevance_differences([], _, acc), do: Enum.reverse(acc)

  defp prevance_differences([head | tail], delta, acc) do
    next_delta = hd(head) - delta
    prevance_differences(tail, next_delta, [[next_delta | head] | acc])
  end

  @spec differences([integer()]) :: [[integer()]]
  defp differences(line, acc \\ []) do
    if Enum.all?(line, &(&1 == 0)) do
      acc
    else
      line
      |> Enum.zip(tl(line))
      |> Enum.map(fn {a, b} -> b - a end)
      |> differences([Enum.reverse(line) | acc])
    end
  end

  @spec parse_input(String.t()) :: [[integer()]]
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end

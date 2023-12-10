defmodule AdventOfCode.Day04 do
  def part1(input) do
    input
    |> parse_input()
    |> count_winners()
    |> Enum.map(fn {_card_id, size} ->
      if size == 0, do: 0, else: 2 ** (size - 1)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> count_winners()
    |> accumulate_cards()
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.sum()
  end

  defp accumulate_cards(cards) do
    counters = cards |> Enum.map(fn {card_id, _} -> {card_id, 1} end) |> Map.new()

    cards
    |> Enum.reduce(counters, fn {card_id, size}, acc ->
      increment = Map.get(acc, card_id)

      if size == 0 do
        acc
      else
        Enum.reduce((card_id + 1)..(card_id + size), acc, fn id, acc ->
          if Map.has_key?(acc, id), do: Map.update!(acc, id, &(&1 + increment)), else: acc
        end)
      end
    end)
  end

  @spec count_winners([{integer(), MapSet.t(), MapSet.t()}]) :: [{integer(), integer()}]
  defp count_winners(cards) do
    cards
    |> Enum.map(fn {card_id, winning_numbers, numbers_you_have} ->
      {card_id, winning_numbers |> MapSet.intersection(numbers_you_have) |> MapSet.size()}
    end)
  end

  @spec parse_input(String.t()) :: [{integer(), MapSet.t(), MapSet.t()}]
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_line/1)
  end

  @spec parse_line(String.t()) :: {integer(), MapSet.t(), MapSet.t()}
  defp parse_line("Card " <> line) do
    {card_id, ":" <> rest} = line |> String.trim() |> Integer.parse()

    [winning_numbers, numbers_you_have] =
      rest
      |> String.trim()
      |> String.split("|")
      |> Enum.map(fn block ->
        block
        |> String.trim()
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()
      end)

    {card_id, winning_numbers, numbers_you_have}
  end
end

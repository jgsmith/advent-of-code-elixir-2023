defmodule AdventOfCode.Day07 do
  def part1(input) do
    input
    |> parse_input()
    |> calculate_winnings()
  end

  def part2(input) do
    input
    |> String.replace("J", "j", global: true)
    |> parse_input()
    |> calculate_winnings()
  end

  defp calculate_winnings(hands) do
    hands
    |> sort_hands()
    |> Enum.with_index()
    |> Enum.map(fn {{_, bid}, rank} -> bid * (rank + 1) end)
    |> Enum.sum()
  end

  defp sort_hands(hands) do
    Enum.sort_by(hands, fn {hand, _} ->
      {hand_type(hand), hand |> Enum.map(&card_strength/1)}
    end)
  end

  @spec hand_type([String.t()]) :: integer()
  defp hand_type(hand) do
    hand
    |> Enum.group_by(& &1)
    |> Enum.group_by(fn {_, cards} -> Enum.count(cards) end)
    |> Enum.map(fn {count, cards} -> {count, Enum.map(cards, &elem(&1, 0))} end)
    |> Map.new()
    |> case do
      # the map has the count of each card kind to the list of cards with that count
      # the sum of keys times their multiplicity has to equal 5,
      # so only 5, 4+1, 3+2, 3+1+1, 2+2+1, 2+1+1+1, 1+1+1+1+1 are possible
      %{5 => _} ->
        :five_of_a_kind

      %{4 => [fours], 1 => [ones]} ->
        if fours == "j" or ones == "j" do
          :five_of_a_kind
        else
          :four_of_a_kind
        end

      %{3 => [three], 2 => [two]} ->
        if three == "j" or two == "j" do
          :five_of_a_kind
        else
          :full_house
        end

      %{3 => [three], 1 => ones} ->
        if three == "j" or "j" in ones do
          :four_of_a_kind
        else
          :three_of_a_kind
        end

      %{2 => [pair1, pair2], 1 => [ones]} ->
        cond do
          pair1 == "j" or pair2 == "j" ->
            :four_of_a_kind

          ones == "j" ->
            :full_house

          :else ->
            :two_pairs
        end

      %{2 => [pair], 1 => ones} ->
        if pair == "j" or "j" in ones do
          :three_of_a_kind
        else
          :one_pair
        end

      %{1 => ones} ->
        if "j" in ones do
          :one_pair
        else
          :high_card
        end
    end
    |> case do
      :five_of_a_kind -> 10
      :four_of_a_kind -> 8
      :full_house -> 6
      :three_of_a_kind -> 4
      :two_pairs -> 2
      :one_pair -> 1
      :high_card -> 0
    end
  end

  defp card_strength("A"), do: 14
  defp card_strength("K"), do: 13
  defp card_strength("Q"), do: 12
  defp card_strength("J"), do: 11
  defp card_strength("T"), do: 10
  defp card_strength("j"), do: 0
  defp card_strength(card), do: String.to_integer(card)

  @spec parse_input(String.t()) :: [{[String.t()], integer()}]
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_hand/1)
  end

  @spec parse_hand(String.t()) :: {[String.t()], integer()}
  defp parse_hand(line) do
    [hand, bid] = String.split(line, " ", trim: true)
    {String.split(hand, "", trim: true), String.to_integer(bid)}
  end
end

defmodule AdventOfCode.Day03 do
  def part1(input) do
    input
    |> parse_input()
    |> find_numbers_next_to_symbols()
    |> Enum.map(&pluck_number/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> find_gears()
    |> calculate_gear_ratios()
    |> Enum.sum()
  end

  @spec pluck_number({integer(), integer(), integer(), integer()}) :: integer()
  defp pluck_number({_index, _start, _stop, value}), do: value

  @spec find_gears({map(), list()}) :: list()
  defp find_gears({symbols, numbers}) do
    numbers
    |> Enum.reduce(%{}, fn number, maybe_gears ->
      # we check all the positions around the number to see if there is a symbol
      ratio = pluck_number(number)

      number
      |> enumerate_positions_around_number()
      |> Enum.filter(&(Map.get(symbols, &1) == "*"))
      |> Enum.reduce(maybe_gears, fn gear, gears ->
        Map.update(gears, gear, [ratio], &[ratio | &1])
      end)
    end)
    |> Enum.filter(fn {_, ratios} -> length(ratios) == 2 end)
  end

  @spec calculate_gear_ratios(list()) :: list()
  defp calculate_gear_ratios(gears) do
    Enum.map(gears, fn {_, ratios} -> Enum.product(ratios) end)
  end

  @spec find_numbers_next_to_symbols({map(), list()}) :: list()
  defp find_numbers_next_to_symbols({symbols, numbers}) do
    numbers
    |> Enum.filter(fn number ->
      # we check all the positions around the number to see if there is a symbol
      number
      |> enumerate_positions_around_number()
      |> Enum.any?(&Map.has_key?(symbols, &1))
    end)
  end

  @spec enumerate_positions_around_number({integer(), integer(), integer(), integer()}) :: list()
  defp enumerate_positions_around_number({index, start, stop, _value}) do
    # we enumerate all the positions around the number
    # we do not include the number itself
    prior_line =
      if index > 0 do
        for pos <- (start - 1)..(stop + 1), do: {index - 1, pos}
      else
        []
      end

    next_line = for pos <- (start - 1)..(stop + 1), do: {index + 1, pos}

    [
      {index, start - 1},
      {index, stop + 1}
    ] ++ prior_line ++ next_line
  end

  # Takes the input and returns a tuple of a map of symbols and a list of numbers.

  # Each symbol maps a position to the symbol.
  # Each number is a tuple of the start and stop position and the value.
  @spec parse_input(String.t()) :: {map(), list()}
  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.map(&parse_line/1)
    |> Enum.reduce({%{}, []}, fn {symbols, numbers}, {symbols_acc, numbers_acc} ->
      {Map.merge(symbols, symbols_acc), numbers ++ numbers_acc}
    end)
  end

  defp parse_line({line, index}) do
    line
    |> parse_line(0, [])
    |> Enum.reduce({%{}, []}, fn {start, stop, value}, {symbols, numbers} ->
      if is_number(value) do
        {symbols, [{index, start, stop, value} | numbers]}
      else
        {Map.put(symbols, {index, start}, value), numbers}
      end
    end)
  end

  defp parse_line("", _pos, acc) do
    acc
  end

  defp parse_line(<<".", rest::binary>>, pos, acc), do: parse_line(rest, pos + 1, acc)

  defp parse_line(<<digit::binary-1, _::binary>> = number_line, pos, acc)
       when digit in ~w(0 1 2 3 4 5 6 7 8 9) do
    [_, number, rest] = Regex.run(~r{^(\d+)(.*)}, number_line)
    new_pos = pos + String.length(number)
    parse_line(rest, new_pos, [{pos, new_pos - 1, String.to_integer(number)} | acc])
  end

  defp parse_line(<<symbol::binary-1, rest::binary>>, pos, acc) do
    parse_line(rest, pos + 1, [{pos, pos, symbol} | acc])
  end
end

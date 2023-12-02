defmodule AdventOfCode.Day02 do
  def part1(input) do
    input
    |> parse_games()
    |> Enum.filter(&possible_game?(&1, {12, 13, 14}))
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_games()
    |> Enum.map(fn {id, sets} ->
      colors =
        Enum.reduce(sets, %{"red" => 0, "blue" => 0, "green" => 0}, fn set, colors ->
          Enum.reduce(set, colors, fn {count, color}, colors ->
            Map.update!(colors, color, &max(&1, count))
          end)
        end)

      colors["red"] * colors["green"] * colors["blue"]
    end)
    |> Enum.sum()
  end

  def possible_game?({_, sets}, {red, green, blue}) do
    Enum.all?(sets, fn set ->
      Enum.all?(set, fn
        {count, "red"} -> count <= red
        {count, "green"} -> count <= green
        {count, "blue"} -> count <= blue
      end)
    end)
  end

  def parse_games(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_game/1)
  end

  def parse_game(line) do
    line
    |> String.trim()
    |> parse_game_id()
    |> parse_pulls()
  end

  def parse_game_id("Game " <> line) do
    # Game (\d+): ...
    {id, ":" <> rest} = Integer.parse(line)
    {id, String.trim(rest)}
  end

  def parse_pulls({id, pulls}) do
    {id,
     pulls
     |> String.split(";")
     |> Enum.map(&parse_pull/1)}
  end

  def parse_pull(pull) do
    pull
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_collection/1)
  end

  def parse_collection(collection) do
    {count, color} =
      collection
      |> String.trim()
      |> Integer.parse()

    {count, String.trim(color)}
  end
end

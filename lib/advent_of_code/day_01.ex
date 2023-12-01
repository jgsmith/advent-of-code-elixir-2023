defmodule AdventOfCode.Day01 do
  def part1(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.replace(&1, ~r{[^0-9]}, ""))
    |> Enum.map(fn x -> String.slice(x, 0, 1) <> String.slice(x, -1, 1) end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.replace(&1, "one", "o1e"))
    |> Enum.map(&String.replace(&1, "two", "t2o"))
    |> Enum.map(&String.replace(&1, "three", "t3e"))
    |> Enum.map(&String.replace(&1, "four", "f4r"))
    |> Enum.map(&String.replace(&1, "five", "f5e"))
    |> Enum.map(&String.replace(&1, "six", "s6x"))
    |> Enum.map(&String.replace(&1, "seven", "s7n"))
    |> Enum.map(&String.replace(&1, "eight", "e8t"))
    |> Enum.map(&String.replace(&1, "nine", "n9e"))
    |> Enum.map(&String.replace(&1, ~r{[^0-9]}, ""))
    |> Enum.map(fn x -> String.slice(x, 0, 1) <> String.slice(x, -1, 1) end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end

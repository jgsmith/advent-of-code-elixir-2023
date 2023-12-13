defmodule AdventOfCode.Day13 do
  @type row :: [String.t()]
  @type block :: [row]
  @type reflection :: {:row, integer()} | {:col, integer()}

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&find_reflection/1)
    |> score()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&find_reflection(&1, 1))
    |> score()
  end

  @spec score([reflection]) :: integer()
  defp score(reflections) do
    reflections
    |> Enum.map(fn
      {:row, row} -> 100 * row
      {:col, col} -> col
    end)
    |> Enum.sum()
  end

  @spec find_reflection(block, integer()) :: reflection
  defp find_reflection(block, epsilon \\ 0) do
    case find_simple_reflection(block, epsilon) do
      nil ->
        {:col, block |> rotate_block() |> find_simple_reflection(epsilon)}

      row ->
        {:row, row}
    end
  end

  @spec distance(row, row) :: integer()
  defp distance(row1, row2) when is_list(row1) and is_list(row2) do
    row1
    |> Enum.zip(row2)
    |> Enum.count(fn
      {a, a} -> false
      {_a, _b} -> true
    end)
  end

  defp distance(nil, row2) when is_list(row2), do: Enum.count(row2)
  defp distance(row1, nil) when is_list(row1), do: Enum.count(row1)

  @spec find_simple_reflection(block, integer()) :: integer() | nil
  defp find_simple_reflection(block, 0) do
    block
    |> tl
    |> Enum.zip(block)
    |> Enum.with_index()
    |> Enum.find(fn
      {{row, row}, index} ->
        # check that we have a real reflection
        block_size = Enum.count(block)
        size = min(index + 1, block_size - index - 1)

        Enum.all?(1..(size - 1), fn i ->
          Enum.at(block, index + i + 1) == Enum.at(block, index - i)
        end)

      _ ->
        false
    end)
    |> case do
      nil -> nil
      {_, index} -> index + 1
    end
  end

  defp find_simple_reflection(block, 1) do
    block
    |> tl
    |> Enum.zip(block)
    |> Enum.with_index()
    |> Enum.find(fn
      {{row, row}, index} ->
        block_size = Enum.count(block)
        size = min(index + 1, block_size - index - 1)

        distances =
          Enum.map(1..(size - 1), fn i ->
            distance(Enum.at(block, index + i + 1), Enum.at(block, index - i))
          end)

        Enum.all?(distances, fn d -> d <= 1 end) and Enum.sum(distances) == 1

      {{row1, row2}, index} ->
        if distance(row1, row2) == 1 do
          block_size = Enum.count(block)
          size = min(index + 1, block_size - index - 1)

          if size == 1 do
            true
          else
            Enum.all?(1..(size - 1), fn i ->
              Enum.at(block, index + i + 1) == Enum.at(block, index - i)
            end)
          end
        else
          false
        end
    end)
    |> case do
      nil -> nil
      {_, index} -> index + 1
    end
  end

  @spec rotate_block(block) :: block
  defp rotate_block([[] | _]), do: []

  defp rotate_block(block) do
    [Enum.map(block, &hd/1) | rotate_block(Enum.map(block, &tl/1))]
  end

  @spec parse_input(String.t()) :: [block]
  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn block ->
      block
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.split("", trim: true)
      end)
    end)
  end
end

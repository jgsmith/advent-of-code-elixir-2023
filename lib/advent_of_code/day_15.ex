defmodule AdventOfCode.Day15 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> organize_lenses()
    |> calculate_focusing_power()
    |> Enum.sum()
  end

  defp calculate_focusing_power(boxes) do
    boxes
    |> Enum.map(fn
      {box_number, lenses} ->
        lenses
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(fn
          {{_, fl}, pos} -> (box_number + 1) * fl * (pos + 1)
        end)
        |> Enum.sum()
    end)
  end

  defp organize_lenses(instructions, boxes \\ %{})
  defp organize_lenses([], boxes), do: boxes

  defp organize_lenses([instruction | instructions], boxes) do
    case String.split(instruction, "=", trim: true) do
      [label, digit] ->
        box = hash(label)
        focal_length = String.to_integer(digit)

        organize_lenses(
          instructions,
          Map.update(boxes, box, [{label, focal_length}], fn labels ->
            existing_lens = Enum.find_index(labels, fn {l, _} -> l == label end)

            if not is_nil(existing_lens) do
              List.replace_at(labels, existing_lens, {label, focal_length})
            else
              [{label, focal_length} | labels]
            end
          end)
        )

      [label] ->
        label = String.trim(label, "-")
        box = hash(label)

        organize_lenses(
          instructions,
          Map.update(boxes, box, [], fn labels ->
            Enum.reject(labels, fn {l, _} -> l == label end)
          end)
        )
    end
  end

  defp hash(string, code \\ 0)
  defp hash("", code), do: code

  defp hash(<<char::8, rest::binary>>, code) do
    hash(rest, rem((code + char) * 17, 256))
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.join("")
    |> String.split(",", trim: true)
  end
end

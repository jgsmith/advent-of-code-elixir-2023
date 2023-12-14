defmodule AdventOfCode.Day14 do
  defstruct map: [],
            min_row: 0,
            max_row: 0,
            min_col: 0,
            max_col: 0

  @type platform :: %AdventOfCode.Day14{}

  def part1(input) do
    input
    |> parse_input()
    |> move_rounded(:north)
    |> score_platform()
  end

  def part2(input) do
    platform =
      input
      |> parse_input()

    {offset, cycle} = find_platform_cycle(platform)
    index = rem(1_000_000_000 - offset, Enum.count(cycle))

    resulting_platform = Enum.at(cycle, index)
    score_platform(resulting_platform)
  end

  @spec find_platform_cycle(platform, [platform]) :: {integer(), [platform]}
  defp find_platform_cycle(platform, acc \\ []) do
    if platform in acc do
      index = Enum.find_index(acc, fn p -> p == platform end)
      {Enum.count(acc) - index - 1, Enum.take(acc, index + 1) |> Enum.reverse()}
    else
      platform
      |> single_platform_cycle()
      |> find_platform_cycle([platform | acc])
    end
  end

  @spec single_platform_cycle(platform) :: platform
  defp single_platform_cycle(platform) do
    platform
    |> move_rounded(:north)
    |> move_rounded(:west)
    |> move_rounded(:south)
    |> move_rounded(:east)
    |> sort_map()
  end

  @spec sort_map(platform) :: platform
  defp sort_map(platform) do
    %{platform | map: Enum.sort(platform.map)}
  end

  @spec group_things([{{integer, integer}, String.t()}], :north | :east | :south | :west) :: [
          {integer, [{integer, String.t()}]}
        ]
  defp group_things(platform_core, direction) do
    if direction in [:east, :west] do
      platform_core
      |> Enum.group_by(fn {{row, _}, _} -> row end)
      |> Enum.map(fn {row, els} ->
        {row, els |> Enum.map(fn {{_, col}, char} -> {col, char} end) |> Enum.sort()}
      end)
    else
      platform_core
      |> Enum.group_by(fn {{_, col}, _} -> col end)
      |> Enum.map(fn {col, els} ->
        {col, els |> Enum.map(fn {{row, _}, char} -> {row, char} end) |> Enum.sort()}
      end)
    end
  end

  @spec move_things(
          platform,
          [{integer, [{integer, String.t()}]}],
          :north | :east | :south | :west
        ) :: platform
  defp move_things(platform, grouped_things, direction) when direction in [:north, :south] do
    target = if direction == :north, do: 0, else: platform.max_row

    shifted_things =
      grouped_things
      |> Enum.flat_map(fn {col, things} ->
        things
        |> compact_rounded(target)
        |> Enum.map(fn {row, char} -> {{row, col}, char} end)
      end)

    %{platform | map: shifted_things}
  end

  defp move_things(platform, grouped_things, direction) when direction in [:east, :west] do
    target = if direction == :west, do: 0, else: platform.max_col

    shifted_things =
      grouped_things
      |> Enum.flat_map(fn {row, things} ->
        things
        |> compact_rounded(target)
        |> Enum.map(fn {col, char} -> {{row, col}, char} end)
      end)

    %{platform | map: shifted_things}
  end

  @spec move_rounded(platform, :north | :east | :south | :west) :: platform
  defp move_rounded(platform, direction) do
    %{map: core} = platform

    grouped_things = group_things(core, direction)

    move_things(platform, grouped_things, direction)
  end

  @spec compact_rounded([{integer, String.t()}], :asc | :desc) :: [{integer, String.t()}]
  defp compact_rounded(items, 0) do
    items
    |> Enum.reduce({0, []}, fn {row, char}, {next_row, acc} ->
      case char do
        "#" -> {row + 1, [{row, char} | acc]}
        "O" -> {next_row + 1, [{next_row, char} | acc]}
      end
    end)
    |> elem(1)
  end

  defp compact_rounded(items, target) do
    items
    |> Enum.reverse()
    |> Enum.reduce({target, []}, fn {idx, char}, {next_idx, acc} ->
      case char do
        "#" -> {idx - 1, [{idx, char} | acc]}
        "O" -> {next_idx - 1, [{next_idx, char} | acc]}
      end
    end)
    |> elem(1)
  end

  defp score_platform(platform) do
    %{map: core, min_row: lower, max_row: upper} = platform
    number_rows = upper - lower + 1

    core
    |> Enum.sort()
    |> Enum.map(fn
      {{row, _}, "O"} -> number_rows - row
      _ -> 0
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    platform_core =
      input
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)

    {min_row, max_row} = platform_core |> Enum.map(fn {{row, _}, _} -> row end) |> Enum.min_max()
    {min_col, max_col} = platform_core |> Enum.map(fn {{_, col}, _} -> col end) |> Enum.min_max()

    %__MODULE__{
      map: platform_core,
      min_row: min_row,
      max_row: max_row,
      min_col: min_col,
      max_col: max_col
    }
  end

  defp parse_line({line, row}) do
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce([], fn {char, col}, things ->
      case char do
        "." -> things
        char -> [{{row, col}, char} | things]
      end
    end)
  end
end

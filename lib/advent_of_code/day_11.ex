defmodule AdventOfCode.Day11 do
  def part1(input) do
    input
    |> parse_input()
    |> find_distances()
    |> Enum.sum()
    |> div(2)
  end

  def part2(input, hubble \\ 1_000_000) do
    input
    |> parse_input()
    |> find_distances(hubble)
    |> Enum.sum()
    |> div(2)
  end

  @spec find_distances([[String.t()]], integer()) :: [integer()]
  defp find_distances(map, hubble \\ 2) do
    galaxies = find_galaxies(map)
    metric = find_expansion_metric(map, galaxies)

    Enum.flat_map(galaxies, fn galaxy ->
      Enum.map(galaxies, fn other_galaxy ->
        find_distance(metric, galaxy, other_galaxy, hubble)
      end)
    end)
  end

  @spec find_distance(
          {[integer()], [integer()]},
          {integer(), integer()},
          {integer(), integer()},
          integer()
        ) :: integer()
  defp find_distance({expanded_rows, expanded_cols}, {r1, c1}, {r2, c2}, hubble) do
    # it's the manhatten distance except we need to add the count of rows/cols
    # between the two points
    {r1, r2} = {min(r1, r2), max(r1, r2)}
    {c1, c2} = {min(c1, c2), max(c1, c2)}

    expanding_rows = Enum.filter(r1..r2, &(&1 in expanded_rows))
    expanding_cols = Enum.filter(c1..c2, &(&1 in expanded_cols))

    r2 - r1 + c2 - c1 + (hubble - 1) * (Enum.count(expanding_rows) + Enum.count(expanding_cols))
  end

  @spec find_expansion_metric([[String.t()]], [{integer(), integer()}]) ::
          {[integer()], [integer()]}
  defp find_expansion_metric(map, galaxies) do
    max_row = Enum.count(map) - 1
    max_col = String.length(hd(map)) - 1
    rows_with_galaxies = galaxies |> Enum.map(fn {row, _} -> row end) |> Enum.uniq()
    cols_with_galaxies = galaxies |> Enum.map(fn {_, col} -> col end) |> Enum.uniq()
    expanded_rows = 0..max_row |> Enum.filter(fn row -> row not in rows_with_galaxies end)
    expanded_cols = 0..max_col |> Enum.filter(fn col -> col not in cols_with_galaxies end)
    {expanded_rows, expanded_cols}
  end

  @spec find_galaxies([[String.t()]]) :: [{integer(), integer()}]
  defp find_galaxies(map) do
    map
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {cell, _} -> cell == "#" end)
      |> Enum.map(fn {_, col_index} -> {row_index, col_index} end)
    end)
  end

  @spec parse_input(String.t()) :: [[String.t()]]
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end
end

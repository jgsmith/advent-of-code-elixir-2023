defmodule AdventOfCode.Day05 do
  def part1(input) do
    info =
      input
      |> parse_input()
      |> make_mappings()

    info
    |> Map.get(:seeds)
    |> Enum.map(&location_for_seed(info, &1))
    |> Enum.min()
  end

  def part2(input) do
    info =
      input
      |> parse_input()
      |> make_mappings()

    info
    |> Map.get(:seeds)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [low, length] -> {low, low + length - 1} end)
    |> Enum.sort()
    |> Enum.map(&location_for_seed(info, &1))
    |> List.flatten()
    |> Enum.min()
    |> elem(0)
  end

  # traverses the mappings for the given seed
  # if the seed is a single number, it will produce a single number
  # if the seed is a range (`{low, high}`), it will produce a list of ranges
  #
  # the different handling of ints vs. ranges is in the `get_mapping` function
  #
  defp location_for_seed(info, seed) do
    %{
      seed_to_soil: seed_to_soil,
      soil_to_fertilizer: soil_to_fertilizer,
      fertilizer_to_water: fertilizer_to_water,
      water_to_light: water_to_light,
      light_to_temperature: light_to_temperature,
      temperature_to_humidity: temperature_to_humidity,
      humidity_to_location: humidity_to_location
    } = info

    seed
    |> get_mapping(seed_to_soil)
    |> get_mapping(soil_to_fertilizer)
    |> get_mapping(fertilizer_to_water)
    |> get_mapping(water_to_light)
    |> get_mapping(light_to_temperature)
    |> get_mapping(temperature_to_humidity)
    |> get_mapping(humidity_to_location)
  end

  defp get_mapping(key, info, acc \\ [])

  # when it's just a number, we return a number
  defp get_mapping(key, info, _) when is_number(key) do
    info
    |> Enum.find(fn {source, _dest, length} ->
      source <= key and key < source + length
    end)
    |> case do
      {source, dest, _length} -> dest + (key - source)
      nil -> key
    end
  end

  # when it's a range, we return a list of 1 or more ranges
  defp get_mapping({low, high}, ranges, acc) do
    ranges
    |> Enum.find(fn {source, _dest, length} ->
      source <= low and low < source + length
    end)
    |> case do
      {source, dest, length} ->
        if high < source + length do
          # we have a single range we can map to
          [{dest + (low - source), dest + (high - source)} | acc]
        else
          # we have to split the range
          get_mapping({source + length, high}, ranges, [
            {dest + (low - source), dest + (length - 1)} | acc
          ])
        end

      nil ->
        # we need to find out how far we can go without an explicit mapping
        ranges
        |> Enum.find(fn {source, _dest, _length} ->
          low < source and source <= high
        end)
        |> case do
          {source, _dest, _length} ->
            # this is the first range that falls in the {low, high} range
            # so up until source, it's a 1-1 mapping
            # {low, source - 1}, {source, high}
            get_mapping({source, high}, ranges, [{low, source - 1} | acc])

          nil ->
            # entire 1-1 mapping now
            [{low, high} | acc]
        end
    end
  end

  # when it's a list, we return a list of mappings for each element in the list
  defp get_mapping(keys, info, _) when is_list(keys) do
    keys
    |> Enum.map(&get_mapping(&1, info))
    |> List.flatten()
  end

  @spec parse_input(String.t()) :: map()
  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> parse_lines([])
  end

  defp make_mappings(info) do
    [seeds] = Map.get(info, "seeds")

    %{
      seeds: seeds,
      seed_to_soil: make_mapping(Map.get(info, "seed-to-soil")),
      soil_to_fertilizer: make_mapping(Map.get(info, "soil-to-fertilizer")),
      fertilizer_to_water: make_mapping(Map.get(info, "fertilizer-to-water")),
      water_to_light: make_mapping(Map.get(info, "water-to-light")),
      light_to_temperature: make_mapping(Map.get(info, "light-to-temperature")),
      temperature_to_humidity: make_mapping(Map.get(info, "temperature-to-humidity")),
      humidity_to_location: make_mapping(Map.get(info, "humidity-to-location"))
    }
  end

  defp make_mapping(lines) do
    lines
    |> Enum.map(fn [dest, source, length] ->
      {source, dest, length}
    end)
    |> Enum.sort()
  end

  @spec parse_lines([String.t()], map()) :: map()
  defp parse_lines([], acc) do
    acc
    |> Enum.reverse()
    # now we want to get the info from the parsed lines
    |> Enum.reduce({%{}, nil}, fn
      label, {info, _} when is_binary(label) ->
        {Map.put_new(info, label, []), label}

      numbers, {info, label} when is_list(numbers) ->
        {Map.update!(info, label, &[numbers | &1]), label}
    end)
    |> elem(0)
  end

  defp parse_lines(["seeds: " <> line | rest], acc) do
    seed_numbers =
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    parse_lines(rest, [seed_numbers, "seeds" | acc])
  end

  defp parse_lines([<<digit::binary-1, _::binary>> = line | rest], acc)
       when digit in ~w(0 1 2 3 4 5 6 7 8 9) do
    numbers =
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    parse_lines(rest, [numbers | acc])
  end

  defp parse_lines([header | rest], acc) do
    parse_lines(rest, [String.replace_suffix(header, " map:", "") | acc])
  end
end

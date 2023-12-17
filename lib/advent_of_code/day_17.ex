defmodule AdventOfCode.Day17 do
  @type state :: {integer, direction, integer, location}
  @type location :: {integer, integer}
  @type direction :: :north | :south | :west | :east

  defstruct direction: :east,
            location: {0, 0},
            heat_loss: 0,
            run_length: 1,
            min_run: 1,
            max_run: 3

  def part1(input) do
    input
    |> parse_input()
    |> find_path([%__MODULE__{direction: :east}, %__MODULE__{direction: :south}])
    |> heat_loss()
  end

  def part2(input) do
    input
    |> parse_input()
    |> find_path([
      %__MODULE__{direction: :east, min_run: 4, max_run: 10},
      %__MODULE__{direction: :south, min_run: 4, max_run: 10}
    ])
    |> heat_loss()
  end

  @spec find_path(tuple(), [state]) :: state
  defp find_path(city_map, starts) do
    goal = {tuple_size(elem(city_map, 0)) - 1, tuple_size(city_map) - 1}

    starts
    |> Enum.reduce(pq_new(), fn start, pq ->
      pq_push(pq, start, distance_to_point(start, goal))
    end)
    |> find_path(goal, city_map, MapSet.new())
  end

  @spec find_path(PriorityQueue.t(), location, tuple(), MapSet.t()) :: state
  defp find_path(pq, goal, city_map, visited) do
    {state, pq} = pq_pop(pq)

    cond do
      reached_goal?(state, goal) ->
        state

      visited?(visited, state) ->
        find_path(pq, goal, city_map, visited)

      :else ->
        state
        |> next_steps(city_map)
        |> Enum.reduce(pq, fn new_state, pq ->
          pq_push(pq, new_state, heat_loss(new_state) + distance_to_point(new_state, goal))
        end)
        |> find_path(goal, city_map, visited(visited, state))
    end
  end

  @spec visited?(MapSet.t(), state) :: boolean()
  defp visited?(visited, state) do
    visit_key = {location(state), direction(state), run_length(state)}
    MapSet.member?(visited, visit_key)
  end

  @spec visited(MapSet.t(), state) :: MapSet.t()
  defp visited(visited, state) do
    visit_key = {location(state), direction(state), run_length(state)}
    MapSet.put(visited, visit_key)
  end

  @spec distance_to_point(state, location) :: integer()
  defp distance_to_point(state, goal) do
    {x, y} = location(state)
    {x_goal, y_goal} = goal

    floor(:math.sqrt((x - x_goal) ** 2 + (y - y_goal) ** 2))
  end

  @spec location(state) :: location
  defp location(%{location: loc}), do: loc

  @spec direction(state) :: direction
  defp direction(%{direction: dir}), do: dir

  @spec heat_loss(state) :: integer()
  defp heat_loss(%{heat_loss: loss}), do: loss

  @spec run_length(state) :: integer()
  defp run_length(%{run_length: length}), do: length

  @spec reached_goal?(state, location) :: boolean()
  defp reached_goal?(%{run_length: run_length, min_run: min_run}, _) when run_length < min_run,
    do: false

  defp reached_goal?(%{location: goal}, goal), do: true
  defp reached_goal?(_, _), do: false

  @spec valid_location?(location, tuple()) :: boolean()
  defp valid_location?({x, y}, city_map) do
    y >= 0 and x >= 0 and y < tuple_size(city_map) and x < tuple_size(elem(city_map, 0))
  end

  @spec cost(location, tuple()) :: integer()
  defp cost({x, y}, city_map) do
    city_map
    |> elem(y)
    |> elem(x)
  end

  @spec next_steps(state, tuple()) :: [state]
  defp next_steps(state, city_map) do
    going_straight(state, city_map) ++
      going_left(state, city_map) ++
      going_right(state, city_map)
  end

  @spec going_straight(state, tuple()) :: [state]
  defp going_straight(%{run_length: run_length, max_run: max_run}, _) when run_length >= max_run,
    do: []

  defp going_straight(state, city_map) do
    count = run_length(state)
    next_loc = next_location(location(state), direction(state))

    if valid_location?(next_loc, city_map) do
      next_cost = heat_loss(state) + cost(next_loc, city_map)

      [
        %{
          state
          | run_length: count + 1,
            location: next_loc,
            heat_loss: next_cost
        }
      ]
    else
      []
    end
  end

  @spec going_left(state, tuple()) :: [state]
  defp going_left(%{run_length: run_length, min_run: min_run}, _) when run_length < min_run,
    do: []

  defp going_left(state, city_map) do
    next_dir = turn_left(direction(state))
    next_loc = next_location(location(state), next_dir)

    if valid_location?(next_loc, city_map) do
      next_cost = heat_loss(state) + cost(next_loc, city_map)

      [
        %{
          state
          | direction: next_dir,
            location: next_loc,
            run_length: 1,
            heat_loss: next_cost
        }
      ]
    else
      []
    end
  end

  @spec going_right(state, tuple()) :: [state]
  defp going_right(%{run_length: run_length, min_run: min_run}, _) when run_length < min_run,
    do: []

  defp going_right(state, city_map) do
    next_dir = turn_right(direction(state))
    next_loc = next_location(location(state), next_dir)

    if valid_location?(next_loc, city_map) do
      next_cost = heat_loss(state) + cost(next_loc, city_map)

      [
        %{
          state
          | direction: next_dir,
            location: next_loc,
            run_length: 1,
            heat_loss: next_cost
        }
      ]
    else
      []
    end
  end

  @spec next_location(location, direction) :: location
  defp next_location({x, y}, :north), do: {x, y - 1}
  defp next_location({x, y}, :south), do: {x, y + 1}
  defp next_location({x, y}, :west), do: {x - 1, y}
  defp next_location({x, y}, :east), do: {x + 1, y}

  @spec turn_left(direction) :: direction
  defp turn_left(:north), do: :west
  defp turn_left(:south), do: :east
  defp turn_left(:west), do: :south
  defp turn_left(:east), do: :north

  @spec turn_right(direction) :: direction
  defp turn_right(:north), do: :east
  defp turn_right(:south), do: :west
  defp turn_right(:west), do: :north
  defp turn_right(:east), do: :south

  @spec pq_new() :: PriorityQueue.t()
  defp pq_new(), do: PriorityQueue.new()

  @spec pq_push(PriorityQueue.t(), state, integer()) :: PriorityQueue.t()
  defp pq_push(pq, state, cost), do: PriorityQueue.push(pq, state, cost)

  @spec pq_pop(PriorityQueue.t()) :: {state, PriorityQueue.t()} | {nil, PriorityQueue.t()}
  defp pq_pop(pq) do
    pq
    |> PriorityQueue.pop()
    |> case do
      {{:value, v}, pq} -> {v, pq}
      {:empty, pq} -> {nil, pq}
    end
  end

  @spec parse_input(String.t()) :: tuple()
  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> List.to_tuple()
  end

  @spec parse_line(String.t()) :: tuple()
  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

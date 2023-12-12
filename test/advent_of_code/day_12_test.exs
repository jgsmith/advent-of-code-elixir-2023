defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  test "part1" do
    input = """
    ????. 1
    """

    result = part1(input)

    assert result == 4

    input = """
    ??????? 2,1
    """

    result = part1(input)

    assert result == 10

    input = """
    ????.######..#####. 1,6,5
    """

    result = part1(input)

    assert result == 4

    input = """
    ???.### 1,1,3
    """

    result = part1(input)

    assert result == 1

    input = """
    .??..??...?##. 1,1,3
    """

    result = part1(input)

    assert result == 4

    input = """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """

    result = part1(input)

    assert result == 21
  end

  test "part2" do
    input = """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
    result = part2(input)

    assert result == 525152

    # input = """
    # ..?.????#?????????? 1,1,1,1,1,4
    # """

    # result = part2(input) |> dbg
  end
end

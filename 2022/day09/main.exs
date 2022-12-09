defmodule Day09 do
  @direction_mapping %{
    ?L => :left,
    ?U => :up,
    ?R => :right,
    ?D => :down
  }

  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(fn <<direction, ?\s>> <> count_string ->
      List.duplicate(@direction_mapping[direction], String.to_integer(count_string))
    end)
    |> Stream.scan({{0, 0}, {0, 0}}, fn direction, {head, tail} ->
      next_head = move(head, direction)

      if touching?(tail, next_head) do
        {next_head, tail}
      else
        {next_head, move_towards(tail, next_head)}
      end
    end)
    |> Enum.reduce(MapSet.new(), fn {_head, tail}, visited_spaces ->
      MapSet.put(visited_spaces, tail)
    end)
    |> MapSet.size()

    # |> Enum.reduce(
    #   %{head: {0, 0}, tail: {0, 0}, tail_visited: MapSet.new()},
    #   fn {direction, count}, state ->
    #     nil
    #   end
    # )
  end

  # def part02(input) do
  #   input
  # end

  defp touching?(left, {rx, ry}) do
    touching_locations =
      for dx <- -1..1, dy <- -1..1 do
        {rx + dx, ry + dy}
      end

    left in touching_locations
  end

  defp move({x, y}, direction) do
    case direction do
      :left -> {x - 1, y}
      :up -> {x, y + 1}
      :right -> {x + 1, y}
      :down -> {x, y - 1}
    end
  end

  defp move_towards({lx, ly}, {rx, ry}) do
    {lx + clamp(rx - lx, -1, 1), ly + clamp(ry - ly, -1, 1)}
  end

  defp clamp(number, minimum, maximum) do
    cond do
      number < minimum -> minimum
      number > maximum -> maximum
      true -> number
    end
  end
end

"./input.txt" |> File.stream!() |> Day09.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day09.part02() |> IO.inspect(label: "part 2")

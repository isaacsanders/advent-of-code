defmodule Day09 do
  @direction_mapping %{
    ?L => :left,
    ?U => :up,
    ?R => :right,
    ?D => :down
  }

  def part01(input) do
    abstract_solution(input, 2)
  end

  def part02(input) do
    abstract_solution(input, 10)
  end

  def abstract_solution(input, n) do
    initial_rope = List.duplicate({0, 0}, n)

    input
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(fn <<direction, ?\s>> <> count_string ->
      List.duplicate(@direction_mapping[direction], String.to_integer(count_string))
    end)
    |> Stream.scan(initial_rope, fn direction, [head | tail] ->
      next_head = move(head, direction)

      [
        next_head
        | Enum.scan(tail, next_head, fn next_tail, next_head ->
            if touching?(next_tail, next_head) do
              next_tail
            else
              move_towards(next_tail, next_head)
            end
          end)
      ]
    end)
    |> Enum.reduce(MapSet.new(), fn rope, visited_spaces ->
      MapSet.put(visited_spaces, List.last(rope))
    end)
    |> MapSet.size()
  end

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
"./input.txt" |> File.stream!() |> Day09.part02() |> IO.inspect(label: "part 2")

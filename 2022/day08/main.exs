defmodule Day08 do
  def part01(input) do
    trees =
      input
      |> Stream.map(&(&1 |> String.trim() |> String.to_charlist()))
      |> Stream.with_index()
      |> Stream.map(fn {line, from_top} ->
        line
        |> Enum.with_index()
        |> Enum.map(fn {height, from_left} -> {height, {from_top, from_left}} end)
      end)
      |> Enum.to_list()

    visible_from_one_side = visible_from_left(trees, MapSet.new())
    rotated_once = rotate(trees)
    visible_from_two_sides = visible_from_left(rotated_once, visible_from_one_side)
    rotated_twice = rotate(rotated_once)
    visible_from_three_sides = visible_from_left(rotated_twice, visible_from_two_sides)
    rotated_thrice = rotate(rotated_twice)
    visible_from_four_sides = visible_from_left(rotated_thrice, visible_from_three_sides)

    MapSet.size(visible_from_four_sides)
  end

  def part02(input) do
    trees =
      input
      |> Stream.map(&(&1 |> String.trim() |> String.to_charlist()))
      |> Stream.with_index()
      |> Stream.map(fn {line, from_top} ->
        line
        |> Enum.with_index()
        |> Enum.map(fn {height, from_left} -> {height, {from_top, from_left}} end)
      end)
      |> Enum.to_list()

    coordinate_to_height =
      trees
      |> List.flatten()
      |> Map.new(fn {height, coordinate} ->
        {coordinate, height}
      end)

    grid_height = length(trees)
    grid_width = length(hd(trees))

    internal_trees =
      for x <- 1..(grid_width - 2), y <- 1..(grid_height - 2), into: MapSet.new() do
        {x, y}
      end

    internal_trees
    |> Enum.map(fn {from_top, from_left} ->
      tree_height = coordinate_to_height[{from_top, from_left}]

      scores =
        [
          for y <- (from_top - 1)..0 do
            coordinate_to_height[{y, from_left}]
          end,
          for x <- (from_left - 1)..0 do
            coordinate_to_height[{from_top, x}]
          end,
          for x <- (from_left + 1)..(grid_width - 1) do
            coordinate_to_height[{from_top, x}]
          end,
          for y <- (from_top + 1)..(grid_height - 1) do
            coordinate_to_height[{y, from_left}]
          end
        ]
        |> Enum.map(fn trees ->
          case Enum.split_while(trees, &(&1 < tree_height)) do
            {visible_trees, []} ->
              Enum.count(visible_trees)

            {visible_trees, [_last_visible_tree | _]} ->
              Enum.count(visible_trees) + 1
          end
        end)

      Enum.product(scores)
    end)
    |> Enum.max()
  end

  defp visible_from_left(trees, visible_trees) do
    Enum.reduce(trees, visible_trees, fn line, visible_trees ->
      line
      |> Enum.reduce([], fn
        tree, [] ->
          [tree]

        {current_height, _current_coordinates} = current_tree,
        [{previous_highest, _previous_coordinates} | _rest] = visible_trees ->
          if previous_highest < current_height do
            [current_tree | visible_trees]
          else
            visible_trees
          end
      end)
      |> Enum.map(fn {_height, coordinates} -> coordinates end)
      |> Enum.reduce(visible_trees, &MapSet.put(&2, &1))
    end)
  end

  defp rotate(trees) do
    height = length(trees)
    width = length(hd(trees))

    for source_x <- 0..(width - 1) do
      for source_y <- (height - 1)..0 do
        tree_at({source_y, source_x}, trees)
      end
    end
  end

  defp tree_at({from_top, from_left}, trees) do
    trees
    |> Enum.at(from_top)
    |> Enum.at(from_left)
  end
end

"./input.txt" |> File.stream!() |> Day08.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!() |> Day08.part02() |> IO.inspect(label: "part 2")

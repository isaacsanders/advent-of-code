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
    input
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
        trees
        |> Enum.at(source_y)
        |> Enum.at(source_x)
      end
    end
  end
end

"./input.txt" |> File.stream!() |> Day08.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day08.part02() |> IO.inspect(label: "part 2")

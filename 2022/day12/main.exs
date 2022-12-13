defmodule Day12 do
  def part01(input) do
    state = create_state(input)

    path =
      a_star(
        state,
        state.starting_point,
        state.ending_point,
        &distance_to_ending_point(&1, state.mapping_to_heights, state.ending_point)
      )

    print_path(path, state.width, state.height)

    length(path) - 1
  end

  def part02(input) do
    state = create_state(input)

    starting_points =
      state.mapping_to_heights
      |> Enum.filter(fn {point, height} ->
        height == ?a
      end)
      |> Enum.map(fn {point, _height} -> point end)

    path =
      starting_points
      |> Enum.map(fn starting_point ->
        a_star(
          state,
          starting_point,
          state.ending_point,
          &distance_to_ending_point(&1, state.mapping_to_heights, state.ending_point)
        )
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.min_by(&length/1)

    print_path(path, state.width, state.height)

    length(path) - 1
  end

  defp create_state(input) do
    Enum.reduce(
      input,
      %{
        current_coordinate: {0, 0},
        mapping_to_heights: %{},
        starting_point: nil,
        ending_point: nil,
        width: 0,
        height: 0
      },
      fn
        "S", %{current_coordinate: {from_left, from_top}} = state ->
          %{
            state
            | starting_point: state.current_coordinate,
              mapping_to_heights: Map.put(state.mapping_to_heights, state.current_coordinate, ?a),
              current_coordinate: {from_left + 1, from_top}
          }

        "E", %{current_coordinate: {from_left, from_top}} = state ->
          %{
            state
            | ending_point: state.current_coordinate,
              mapping_to_heights: Map.put(state.mapping_to_heights, state.current_coordinate, ?z),
              current_coordinate: {from_left + 1, from_top}
          }

        "\n", %{current_coordinate: {from_left, from_top}} = state ->
          %{
            state
            | current_coordinate: {0, from_top + 1},
              width: from_left,
              height: from_top + 1
          }

        <<height>>, %{current_coordinate: {from_left, from_top}} = state ->
          %{
            state
            | mapping_to_heights:
                Map.put(state.mapping_to_heights, state.current_coordinate, height),
              current_coordinate: {from_left + 1, from_top}
          }
      end
    )
  end

  defp connected_coordinates({from_left, from_top}, mapping_to_heights) do
    height = mapping_to_heights[{from_left, from_top}]

    for {d_left, d_top} <- [{-1, 0}, {0, -1}, {0, 1}, {1, 0}],
        neighbor = mapping_to_heights[{from_left + d_left, from_top + d_top}],
        !is_nil(neighbor) and neighbor in ?a..(height + 1) do
      {from_left + d_left, from_top + d_top}
    end
  end

  defp print_path(path, width, height) do
    directions =
      path
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(%{}, fn [{left_from_left, left_from_top}, {right_from_left, right_from_top}],
                             directions ->
        direction =
          case {right_from_left - left_from_left, right_from_top - left_from_top} do
            {-1, 0} -> "<"
            {0, -1} -> "^"
            {0, 1} -> "v"
            {1, 0} -> ">"
          end

        Map.put(directions, {left_from_left, left_from_top}, direction)
      end)

    for from_top <- 0..height do
      for from_left <- 0..(width - 1) do
        Map.get(directions, {from_left, from_top}, ".")
      end
    end
    |> Enum.intersperse(?\n)
    |> :erlang.iolist_to_binary()
    |> IO.puts()
  end

  defp a_star(state, start, goal, heuristic) do
    open_set = MapSet.new([start])
    came_from = Map.new()
    minimum_distance_from_start = %{start => 0}
    estimated_distance_to_end = Map.new()

    a_star_helper(
      state,
      open_set,
      came_from,
      minimum_distance_from_start,
      estimated_distance_to_end,
      goal,
      heuristic
    )
  end

  defp a_star_helper(
         state,
         open_set,
         came_from,
         minimum_distance_from_start,
         estimated_distance_to_end,
         goal,
         heuristic
       ) do
    if Enum.empty?(open_set) do
      nil
    else
      current = Enum.min_by(open_set, &Map.get(estimated_distance_to_end, &1, :infinity))

      if current == goal do
        reconstruct_path(came_from, current)
      else
        {came_from, minimum_distance_from_start, estimated_distance_to_end, open_set} =
          current
          |> connected_coordinates(state.mapping_to_heights)
          |> Enum.reduce(
            {came_from, minimum_distance_from_start, estimated_distance_to_end,
             MapSet.delete(open_set, current)},
            fn neighbor,
               {came_from, minimum_distance_from_start, estimated_distance_to_end, open_set} ->
              tentative_minimum_distance_from_start = minimum_distance_from_start[current] + 1

              if tentative_minimum_distance_from_start <
                   Map.get(minimum_distance_from_start, neighbor) do
                {
                  Map.put(came_from, neighbor, current),
                  Map.put(
                    minimum_distance_from_start,
                    neighbor,
                    tentative_minimum_distance_from_start
                  ),
                  Map.put(
                    estimated_distance_to_end,
                    neighbor,
                    tentative_minimum_distance_from_start + heuristic.(neighbor)
                  ),
                  MapSet.put(open_set, neighbor)
                }
              else
                {came_from, minimum_distance_from_start, estimated_distance_to_end, open_set}
              end
            end
          )

        a_star_helper(
          state,
          open_set,
          came_from,
          minimum_distance_from_start,
          estimated_distance_to_end,
          goal,
          heuristic
        )
      end
    end
  end

  defp distance_to_ending_point(
         {from_left, from_top} = point,
         mapping_to_heights,
         {ending_left, ending_top} = ending_point
       ) do
    :math.sqrt(:math.pow(mapping_to_heights[point] - mapping_to_heights[ending_point], 2))
  end

  defp reconstruct_path(came_from, point, path \\ []) do
    reconstruct_path_helper(came_from, point, [point])
  end

  defp reconstruct_path_helper(came_from, point, path) do
    case Map.fetch(came_from, point) do
      {:ok, previous} ->
        reconstruct_path_helper(came_from, previous, [previous | path])

      :error ->
        path
    end
  end
end

"./input.txt" |> File.stream!([], 1) |> Day12.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!([], 1) |> Day12.part02() |> IO.inspect(label: "part 2")

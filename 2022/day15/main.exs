defmodule Day15 do
  require IEx

  @line_regex ~r/Sensor at x=(?<sensor_x>-?\d+), y=(?<sensor_y>-?\d+): closest beacon is at x=(?<beacon_x>-?\d+), y=(?<beacon_y>-?\d+)/

  def part01(input) do
    target_y = 2_000_000

    {sensor_to_closest_beacon, beacon_set} =
      input
      |> Stream.map(&String.trim/1)
      |> Stream.map(&parse/1)
      |> Enum.reduce({Map.new(), MapSet.new()}, fn {sensor, beacon},
                                                   {sensor_to_closest_beacon, beacon_set} ->
        {Map.put(sensor_to_closest_beacon, sensor, beacon), MapSet.put(beacon_set, beacon)}
      end)

    row_to_beacons = Enum.group_by(beacon_set, fn {_x, y} -> y end)

    ranges =
      sensor_to_closest_beacon
      |> Enum.map(fn {sensor, beacon} ->
        distance = manhattan_distance(sensor, beacon)
        x_from_point_on_fixed_y(sensor, distance, target_y)
      end)
      |> Enum.filter(fn
        {:ok, _range} -> true
        :error -> false
      end)
      |> Enum.map(fn {:ok, range} -> range end)
      |> collapse_ranges()

    beacons_in_target_row = Map.get(row_to_beacons, target_y, [])

    range_to_beacons = Map.new(ranges, &{&1, []})

    Enum.reduce(beacons_in_target_row, range_to_beacons, fn {beacon_x, beacon_y},
                                                            range_to_beacons ->
      case Enum.filter(ranges, &Enum.member?(&1, beacon_x)) do
        [] ->
          range_to_beacons

        [range] ->
          update_in(range_to_beacons, [Access.key(range, [])], &[{beacon_x, beacon_y} | &1])
      end
    end)
    |> Enum.map(fn {range, beacons} ->
      Enum.count(range) - length(beacons)
    end)
    |> Enum.sum()
  end

  def part02(input) do
    {sensor_to_closest_beacon, _beacon_set} =
      input
      |> Stream.map(&String.trim/1)
      |> Stream.map(&parse/1)
      |> Enum.reduce({Map.new(), MapSet.new()}, fn {sensor, beacon},
                                                   {sensor_to_closest_beacon, beacon_set} ->
        {Map.put(sensor_to_closest_beacon, sensor, beacon), MapSet.put(beacon_set, beacon)}
      end)

    sensor_to_distance_from_beacon =
      Map.new(sensor_to_closest_beacon, fn {sensor, beacon} ->
        {sensor, manhattan_distance(sensor, beacon)}
      end)

    x_bounds = 0..4_000_000
    y_bounds = 0..4_000_000
    bounds = {x_bounds, y_bounds}

    [{solution_bounds, 1} | _rest] =
      [{bounds, bounds_size(bounds)}]
      |> Stream.iterate(fn bounds_list ->
        bounds_list =
          Enum.map(bounds_list, fn {bounds, _size} ->
            bounds
          end)

        find_lowest_coverage_quadrant(sensor_to_distance_from_beacon, bounds_list)
      end)
      |> Stream.drop_while(fn [{_bounds, size} | _rest] -> size > 1 end)
      |> Enum.at(0)

    case solution_bounds do
      {x_bounds, y_bounds} ->
        x_bounds.first * 4_000_000 + y_bounds.first
    end
  end

  defp parse(line) do
    case Regex.named_captures(@line_regex, line) do
      %{
        "beacon_x" => beacon_x,
        "beacon_y" => beacon_y,
        "sensor_x" => sensor_x,
        "sensor_y" => sensor_y
      } ->
        {{String.to_integer(sensor_x), String.to_integer(sensor_y)},
         {String.to_integer(beacon_x), String.to_integer(beacon_y)}}
    end
  end

  defp manhattan_distance({left_x, left_y}, {right_x, right_y}) do
    abs(left_x - right_x) + abs(left_y - right_y)
  end

  defp x_from_point_on_fixed_y({left_x, left_y}, distance, right_y) do
    y_distance_component = abs(left_y - right_y)
    x_distance_component = distance - y_distance_component

    if x_distance_component >= 0 do
      [first, last] = Enum.sort([x_distance_component + left_x, -x_distance_component + left_x])
      {:ok, first..last}
    else
      :error
    end
  end

  defp collapse_ranges(ranges, new_ranges \\ [])

  defp collapse_ranges([], new_ranges) do
    new_ranges
  end

  defp collapse_ranges([range | rest], new_ranges) do
    case Enum.split_with(rest, &Range.disjoint?(range, &1)) do
      {[], []} ->
        [range | new_ranges]

      {non_overlapping, [first_overlapping | rest_overlapping]} ->
        new_range =
          Range.new(
            min(range.first, first_overlapping.first),
            max(range.last, first_overlapping.last)
          )

        collapse_ranges([new_range | non_overlapping ++ rest_overlapping], new_ranges)
    end
  end

  defp print_low_resolution_grid(
         sensor_to_closest_beacon,
         x_bounds,
         y_bounds,
         x_scaling,
         y_scaling
       ) do
    sensors = MapSet.new(sensor_to_closest_beacon, fn {sensor, _beacon} -> sensor end)
    beacons = MapSet.new(sensor_to_closest_beacon, fn {_sensor, beacon} -> beacon end)

    sensor_to_distance_from_beacon =
      Map.new(sensor_to_closest_beacon, fn {sensor, beacon} ->
        {sensor, manhattan_distance(sensor, beacon)}
      end)

    for [first_y, last_y] <-
          Range.new(y_bounds.first, y_bounds.last, y_scaling) |> Enum.chunk_every(2, 1),
        range_y = first_y..(last_y - 1) do
      for [first_x, last_x] <-
            Range.new(x_bounds.first, x_bounds.last, x_scaling) |> Enum.chunk_every(2, 1),
          range_x = first_x..(last_x - 1) do
        corners = [
          {first_x, first_y},
          {first_x, last_y - 1},
          {last_x - 1, first_y},
          {last_x - 1, last_y - 1}
        ]

        [
          (Enum.any?(sensors, fn {sensor_x, sensor_y} ->
             Enum.member?(range_x, sensor_x) and Enum.member?(range_y, sensor_y)
           end) && ?S) || ?.,
          (Enum.any?(beacons, fn {beacon_x, beacon_y} ->
             Enum.member?(range_x, beacon_x) and Enum.member?(range_y, beacon_y)
           end) && ?B) || ?.,
          (Enum.all?(corners, fn corner ->
             Enum.any?(sensor_to_distance_from_beacon, fn {sensor, distance} ->
               manhattan_distance(sensor, corner) <= distance
             end)
           end) && ?#) || ?.
        ]
      end
      |> Enum.intersperse(?\s)
    end
    |> Enum.intersperse(?\n)
    |> :erlang.iolist_to_binary()
    |> IO.puts()
  end

  defp find_lowest_coverage_quadrant(sensor_to_distance_from_beacon, [{x_bounds, y_bounds} | rest]) do
    process_bounds = fn bounds_list ->
      bounds_list
      |> Kernel.++(rest)
      |> Enum.reject(fn bounds ->
        Enum.any?(sensor_to_distance_from_beacon, fn {sensor, distance} ->
          covers_bounds?(sensor, distance, bounds)
        end)
      end)
      |> Enum.map(fn bounds ->
        {bounds, bounds_size(bounds)}
      end)
      |> Enum.sort_by(fn {_, size} -> size end)
    end

    cond do
      Enum.count(x_bounds) > 1 and Enum.count(y_bounds) > 1 ->
        {left_x_half, right_x_half} = split_bounds(x_bounds)
        {left_y_half, right_y_half} = split_bounds(y_bounds)

        process_bounds.([
          {left_x_half, left_y_half},
          {left_x_half, right_y_half},
          {right_x_half, left_y_half},
          {right_x_half, right_y_half}
        ])

      Enum.count(x_bounds) > 1 ->
        {left_x_half, right_x_half} = split_bounds(x_bounds)

        process_bounds.([
          {left_x_half, y_bounds},
          {right_x_half, y_bounds}
        ])

      Enum.count(y_bounds) > 1 ->
        {left_y_half, right_y_half} = split_bounds(y_bounds)

        process_bounds.([
          {x_bounds, left_y_half},
          {x_bounds, right_y_half}
        ])

      true ->
        [{{x_bounds, y_bounds}, bounds_size({x_bounds, y_bounds})}]
    end
  end

  defp covers_bounds?(sensor, distance, {x_bounds, y_bounds}) do
    Enum.all?(corners(x_bounds, y_bounds), &covers_point?(sensor, distance, &1))
  end

  defp covers_point?(sensor, distance, point) do
    manhattan_distance(sensor, point) <= distance
  end

  defp corners(x_bounds, y_bounds) do
    [
      {x_bounds.first, y_bounds.first},
      {x_bounds.first, y_bounds.last},
      {x_bounds.last, y_bounds.first},
      {x_bounds.last, y_bounds.last}
    ]
  end

  defp split_bounds(range) do
    {first, last} = {min(range.first, range.last), max(range.first, range.last)}

    case {div(last - first, 2), rem(last - first, 1)} do
      {width, 0} ->
        {first..(first + width), (first + width + 1)..last}
    end
  end

  defp bounds_size({x_bounds, y_bounds}) do
    Enum.count(x_bounds) * Enum.count(y_bounds)
  end
end

"./input.txt" |> File.stream!() |> Day15.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!() |> Day15.part02() |> IO.inspect(label: "part 2")

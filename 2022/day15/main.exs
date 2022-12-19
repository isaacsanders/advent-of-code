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
    input
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
end

"./input.txt"
|> File.stream!()
|> Day15.part01()
|> IO.inspect(label: "part 1", charlists: :as_lists)

# "./input.txt" |> File.stream!() |> Day15.part02() |> IO.inspect(label: "part 2")

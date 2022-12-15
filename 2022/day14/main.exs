defmodule Day14 do
  @source {500, 0}
  @blocking_material [:rock, :sand]

  def part01(input) do
    state = create_state(input)

    bottom =
      state
      |> Map.keys()
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    final_state =
      state
      |> Stream.iterate(&drop_sand(&1, bottom))
      |> Stream.chunk_every(2, 1)
      |> Stream.drop_while(fn [left, right] ->
        left != right
      end)
      |> Enum.at(0)
      |> Enum.at(0)

    print_state(final_state)

    final_state
    |> Map.values()
    |> Enum.frequencies()
    |> Map.get(:sand)
  end

  def part02(input) do
    input
  end

  defp drop_sand(state, bottom, current_location \\ @source)

  defp drop_sand(state, bottom, {from_left, from_top}) when from_top == bottom + 1 do
    Map.put(state, {from_left, from_top}, :falling_sand)
  end

  defp drop_sand(state, bottom, {from_left, from_top}) when is_integer(bottom) do
    case Map.fetch(state, {from_left, from_top + 1}) do
      {:ok, :falling_sand} ->
        Map.put_new(state, {from_left, from_top}, :falling_sand)

      {:ok, material} when material in @blocking_material ->
        case Map.fetch(state, {from_left - 1, from_top + 1}) do
          {:ok, :falling_sand} ->
            Map.put_new(state, {from_left, from_top}, :falling_sand)

          {:ok, material} when material in @blocking_material ->
            case Map.fetch(state, {from_left + 1, from_top + 1}) do
              {:ok, :falling_sand} ->
                Map.put_new(state, {from_left, from_top}, :falling_sand)

              {:ok, material} when material in @blocking_material ->
                Map.put(state, {from_left, from_top}, :sand)

              :error ->
                drop_sand(state, bottom, {from_left + 1, from_top + 1})
            end

          :error ->
            drop_sand(state, bottom, {from_left - 1, from_top + 1})
        end

      :error ->
        drop_sand(state, bottom, {from_left, from_top + 1})
    end
  end

  defp print_state(state) do
    coordinates = Map.keys(state)

    {left, right} =
      coordinates
      |> Enum.map(&elem(&1, 0))
      |> Enum.min_max()

    bottom =
      coordinates
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    for y <- 0..bottom do
      for x <- left..right do
        case Map.get(state, {x, y}, :air) do
          :source -> "+"
          :rock -> "#"
          :air -> "."
          :sand -> "o"
          :falling_sand -> "~"
        end
      end
    end
    |> Enum.intersperse(?\n)
    |> IO.puts()
  end

  defp create_state(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_segments/1)
    |> Enum.reduce(%{@source => :source}, fn segments, state ->
      segments
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(state, fn
        [{from_left, left_from_top}, {from_left, right_from_top}], state ->
          Enum.reduce(left_from_top..right_from_top, state, fn from_top, state ->
            Map.put(state, {from_left, from_top}, :rock)
          end)

        [{left_from_left, from_top}, {right_from_left, from_top}], state ->
          Enum.reduce(left_from_left..right_from_left, state, fn from_left, state ->
            Map.put(state, {from_left, from_top}, :rock)
          end)
      end)
    end)
  end

  defp parse_segments(line, segment_points \\ []) do
    case Integer.parse(line) do
      {from_left, "," <> rest} ->
        case Integer.parse(rest) do
          {from_top, " -> " <> rest} ->
            parse_segments(rest, [{from_left, from_top} | segment_points])

          {from_top, ""} ->
            Enum.reverse([{from_left, from_top} | segment_points])
        end
    end
  end
end

"./test.txt" |> File.stream!() |> Day14.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day14.part02() |> IO.inspect(label: "part 2")

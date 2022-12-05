defmodule Day04 do
  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.filter(fn row ->
      {left_start..left_end, right_start..right_end} = parse_row(row)

      (left_start <= right_start && left_end >= right_end) ||
        (left_start >= right_start && left_end <= right_end)
    end)
    |> Enum.count()
  end

  def part02(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.reject(fn row ->
      {left, right} = parse_row(row)

      Range.disjoint?(left, right)
    end)
    |> Enum.count()
  end

  defp parse_row(row) do
    {left_start, "-" <> rest} = Integer.parse(row)
    {left_end, "," <> rest} = Integer.parse(rest)
    {right_start, "-" <> rest} = Integer.parse(rest)
    {right_end, ""} = Integer.parse(rest)

    {left_start..left_end, right_start..right_end}
  end
end

"./input.txt" |> File.stream!() |> Day04.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!() |> Day04.part02() |> IO.inspect(label: "part 2")

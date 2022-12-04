defmodule Day01 do
  def part1(input) do
    input
    |> elves()
    |> Stream.map(&Enum.sum/1)
    |> Enum.max()
  end

  def part2(input) do
    input
    |> elves()
    |> Stream.map(&Enum.sum/1)
    |> Enum.reduce([], fn item, top3 ->
      [item | top3]
      |> Enum.sort(:desc)
      |> Enum.take(3)
    end)
    |> Enum.sum()
  end

  defp elves(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.take_every(2)
    |> Stream.map(fn chunk ->
      chunk
      |> Enum.map(&String.to_integer/1)
    end)
  end
end

"./input.txt" |> File.stream!() |> Day01.part1() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!() |> Day01.part2() |> IO.inspect(label: "part 2")

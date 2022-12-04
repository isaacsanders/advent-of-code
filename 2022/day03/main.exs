defmodule Day03 do
  @priorities Map.new(Enum.zip(?a..?z, 1..26) ++ Enum.zip(?A..?Z, 27..52))

  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn rucksack ->
      halfway = div(String.length(rucksack), 2)
      {first, second} = String.split_at(rucksack, halfway)

      in_common =
        MapSet.intersection(
          first |> to_charlist |> MapSet.new(),
          second |> to_charlist |> MapSet.new()
        )

      in_common
      |> Enum.map(&Map.fetch!(@priorities, &1))
      |> Enum.sum()
    end)
    |> Enum.reduce(&Kernel.+/2)
  end

  def part02(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_every(3)
    |> Stream.flat_map(fn group ->
      group
      |> Enum.map(&(&1 |> to_charlist |> MapSet.new()))
      |> Enum.reduce(&MapSet.intersection/2)
      |> Enum.to_list()
      |> Enum.map(&Map.fetch!(@priorities, &1))
    end)
    |> Enum.sum()
  end
end

"./input.txt" |> File.stream!() |> Day03.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!() |> Day03.part02() |> IO.inspect(label: "part 2")

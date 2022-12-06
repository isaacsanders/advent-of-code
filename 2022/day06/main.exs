defmodule Day06 do
  def part01(input) do
    abstract_answer(input, 4)
  end

  def part02(input) do
    abstract_answer(input, 14)
  end

  defp abstract_answer(input, count) do
    input
    |> Stream.chunk_every(count, 1)
    |> Stream.with_index(count)
    |> Enum.find_value(fn {bytes, index} ->
      if length(Enum.uniq(bytes)) == count do
        index
      end
    end)
  end
end

"./input.txt" |> File.stream!([], 1) |> Day06.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!([], 1) |> Day06.part02() |> IO.inspect(label: "part 2")

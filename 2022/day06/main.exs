defmodule Day06 do
  def part01(input) do
    input
    |> Stream.chunk_every(4, 1)
    |> Stream.with_index(4)
    |> Enum.find_value(fn {bytes, index} ->
      if length(Enum.uniq(bytes)) == 4 do
        index
      end
    end)
  end
end

"./input.txt" |> File.stream!([], 1) |> Day06.part01() |> IO.inspect(label: "part 1")

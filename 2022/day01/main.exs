"./input.txt"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.chunk_by(&(&1 == ""))
|> Stream.take_every(2)
|> Stream.map(fn chunk ->
  chunk
  |> Enum.map(&String.to_integer/1)
  |> Enum.sum()
end)
|> Enum.max()
|> IO.inspect()

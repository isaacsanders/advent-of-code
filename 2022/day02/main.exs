defmodule Day02 do
  def score(<<?A, ?\s, ?X>>) do
    1 + 3
  end

  def score(<<?A, ?\s, ?Y>>) do
    2 + 6
  end

  def score(<<?A, ?\s, ?Z>>) do
    3 + 0
  end

  def score(<<?B, ?\s, ?X>>) do
    1 + 0
  end

  def score(<<?B, ?\s, ?Y>>) do
    2 + 3
  end

  def score(<<?B, ?\s, ?Z>>) do
    3 + 6
  end

  def score(<<?C, ?\s, ?X>>) do
    1 + 6
  end

  def score(<<?C, ?\s, ?Y>>) do
    2 + 0
  end

  def score(<<?C, ?\s, ?Z>>) do
    3 + 3
  end
end

"./input.txt"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&Day02.score/1)
|> Enum.reduce(&Kernel.+/2)
|> IO.inspect(label: "part 1")

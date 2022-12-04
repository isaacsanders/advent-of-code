defmodule Day02 do
  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&score_part01/1)
    |> Enum.reduce(&Kernel.+/2)
  end

  defp score_part01(<<?A, ?\s, ?X>>) do
    1 + 3
  end

  defp score_part01(<<?A, ?\s, ?Y>>) do
    2 + 6
  end

  defp score_part01(<<?A, ?\s, ?Z>>) do
    3 + 0
  end

  defp score_part01(<<?B, ?\s, ?X>>) do
    1 + 0
  end

  defp score_part01(<<?B, ?\s, ?Y>>) do
    2 + 3
  end

  defp score_part01(<<?B, ?\s, ?Z>>) do
    3 + 6
  end

  defp score_part01(<<?C, ?\s, ?X>>) do
    1 + 6
  end

  defp score_part01(<<?C, ?\s, ?Y>>) do
    2 + 0
  end

  defp score_part01(<<?C, ?\s, ?Z>>) do
    3 + 3
  end

  def part02(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&score_part02/1)
    |> Enum.reduce(&Kernel.+/2)
  end

  defp score_part02(<<?A, ?\s, ?X>>) do
    3 + 0
  end

  defp score_part02(<<?A, ?\s, ?Y>>) do
    1 + 3
  end

  defp score_part02(<<?A, ?\s, ?Z>>) do
    2 + 6
  end

  defp score_part02(<<?B, ?\s, ?X>>) do
    1 + 0
  end

  defp score_part02(<<?B, ?\s, ?Y>>) do
    2 + 3
  end

  defp score_part02(<<?B, ?\s, ?Z>>) do
    3 + 6
  end

  defp score_part02(<<?C, ?\s, ?X>>) do
    2 + 0
  end

  defp score_part02(<<?C, ?\s, ?Y>>) do
    3 + 3
  end

  defp score_part02(<<?C, ?\s, ?Z>>) do
    1 + 6
  end
end

"./input.txt" |> File.stream!() |> Day02.part01() |> IO.inspect(label: "part 1")
"./input.txt" |> File.stream!() |> Day02.part02() |> IO.inspect(label: "part 2")

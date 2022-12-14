defmodule Day13 do
  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_every(2, 3)
    |> Stream.map(fn chunk ->
      chunk
      |> Enum.map(&Code.eval_string/1)
      |> Enum.map(fn {value, _binding} -> value end)
    end)
    |> Stream.with_index(1)
    |> Enum.filter(fn {[left, right], _index} ->
      {:conclusive, result} = in_order?(left, right)
      result
    end)
    |> Enum.map(fn {_pair, index} -> index end)
    |> Enum.sum()
  end

  def part02(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(fn line ->
      {value, _binding} = Code.eval_string(line)
      value
    end)
    |> Stream.concat([[[2]], [[6]]])
    |> Enum.sort(fn left, right ->
      {:conclusive, result} = in_order?(left, right)
      result
    end)
    |> Enum.with_index(1)
    |> Map.new()
    |> Map.take([[[2]], [[6]]])
    |> Map.values()
    |> Enum.product()
  end

  def in_order?(left, right)

  def in_order?(left, right) when is_integer(left) and is_integer(right) do
    # IO.inspect({left, right}, label: "integers")

    cond do
      left < right ->
        {:conclusive, true}

      left > right ->
        {:conclusive, false}

      left == right ->
        :inconclusive
    end
  end

  def in_order?([], []) do
    # IO.inspect({[], []}, label: "empty lists")
    :inconclusive
  end

  def in_order?([left_head | left_tail], [right_head | right_tail]) do
    # IO.inspect({left_head, right_head}, label: "matched cons cells")

    case in_order?(left_head, right_head) do
      {:conclusive, result} ->
        {:conclusive, result}

      :inconclusive ->
        in_order?(left_tail, right_tail)
    end
  end

  def in_order?([], right) when is_list(right) do
    # IO.inspect({[], right}, label: "left empty")
    {:conclusive, true}
  end

  def in_order?(left, []) when is_list(left) do
    # IO.inspect({left, []}, label: "right empty")
    {:conclusive, false}
  end

  def in_order?(left, right) when not (is_list(left) and is_list(right)) do
    # IO.inspect({left, right}, label: "list wrapping head")
    in_order?(List.wrap(left), List.wrap(right))
  end
end

"./input.txt" |> File.stream!() |> Day13.part01() |> IO.inspect(label: "part 1")

"./input.txt"
|> File.stream!()
|> Day13.part02()
|> IO.inspect(label: "part 2", charlists: :as_lists, limit: :infinity, width: 400)

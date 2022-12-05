defmodule Day05 do
  @type crates() :: {:unprocessed, list(String.t())} | {:processed, list(list(char()))}

  def part01(input) do
    {true, {:processed, crates}} =
      input
      |> Stream.map(&String.trim_trailing(&1, "\n"))
      |> Enum.reduce({false, {:unprocessed, []}}, fn
        "", {_processed_crates? = false, {:unprocessed, crates}} ->
          {true, {:processed, process_crates(crates)}}

        row, {_processed_crates? = false, {:unprocessed, crates}} ->
          {false, {:unprocessed, [row | crates]}}

        row, {processed_crates?, {:processed, crates}} ->
          case parse_move(row) do
            {:ok, move} ->
              {processed_crates?, {:processed, handle_move(move, crates)}}
          end
      end)

    Enum.map(crates, &List.first/1)
  end

  def part02(input) do
    input
  end

  defp process_crates([columns_line | crates]) do
    columns_count = columns_line |> process_labels() |> length

    crates
    |> Enum.map(&process_row/1)
    |> Enum.reduce(List.duplicate([], columns_count), fn crate_level, crates ->
      crate_level
      |> Enum.zip(crates)
      |> Enum.map(fn {item, stack} ->
        [item | stack]
      end)
    end)
    |> Enum.map(fn stack ->
      Enum.drop_while(stack, &is_nil/1)
    end)
  end

  defp process_labels(row, data \\ [])

  defp process_labels(<<?\s, label, ?\s>>, data) do
    Enum.reverse([label | data])
  end

  defp process_labels(<<?\s, label, ?\s>> <> " " <> rest, data) do
    process_labels(rest, [label | data])
  end

  defp process_row(row, data \\ [])

  defp process_row(<<?[, datum, ?]>>, data) do
    Enum.reverse([datum | data])
  end

  defp process_row("   ", data) do
    Enum.reverse([nil | data])
  end

  defp process_row("   " <> " " <> rest, data) do
    process_row(rest, [nil | data])
  end

  defp process_row(<<?[, datum, ?]>> <> " " <> rest, data) do
    process_row(rest, [datum | data])
  end

  defp parse_move(row, state \\ :start)

  defp parse_move("move " <> rest, :start) do
    {move_count, " " <> rest} = Integer.parse(rest)
    parse_move(rest, {:move, move_count})
  end

  defp parse_move("from " <> rest, {:move, move_count}) do
    {from_column, " " <> rest} = Integer.parse(rest)
    parse_move(rest, {:move_from, move_count, from_column - 1})
  end

  defp parse_move("to " <> rest, {:move_from, move_count, from_column}) do
    {to_column, ""} = Integer.parse(rest)
    {:ok, {move_count, from_column, to_column - 1}}
  end

  defp handle_move({move_count, from_column, to_column}, crates) do
    {moving, staying} =
      crates
      |> Enum.at(from_column)
      |> Enum.split(move_count)

    crates
    |> List.replace_at(from_column, staying)
    |> List.update_at(to_column, fn current ->
      Enum.reverse(moving) ++ current
    end)
  end
end

"./input.txt" |> File.stream!() |> Day05.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day05.part02() |> IO.inspect(label: "part 2")

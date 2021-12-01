defmodule Day01 do
  @moduledoc """
  Documentation for `Day01`.
  """

  def run do
    {:ok, input} =
      :day01
      |> :code.priv_dir()
      |> Path.join("input.txt")
      |> File.read()

    input
    |> String.splitter("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> count_increases
  end

  defp count_increases(measurements, increases \\ 0)

  defp count_increases([first, second | tail], increases) do
    if first < second do
      count_increases([second | tail], increases + 1)
    else
      count_increases([second | tail], increases)
    end
  end

  defp count_increases([_first], increases) do
    increases
  end
end

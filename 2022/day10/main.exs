defmodule Day10 do
  @register_starting_value 1

  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn
      "noop" ->
        :noop

      "addx " <> value ->
        {:addx, String.to_integer(value)}
    end)
    |> Stream.concat(Stream.repeatedly(fn -> :eof end))
    |> Stream.transform(
      {@register_starting_value, 0, :queue.new()},
      fn command, {register, pc, cpu} ->
        case process_commands(register, cpu) do
          {_next_register, :eof} ->
            {:halt, {register, pc, cpu}}

          {next_register, next_cpu} ->
            acc = {next_register, pc + 1, add_command(next_cpu, command)}
            {[acc], acc}
        end
      end
    )
    |> Stream.map(fn {register, pc, _cpu} -> register * pc end)
    |> Stream.drop(19)
    |> Enum.take_every(40)
    |> Enum.sum()
  end

  def part02(input) do
    input
  end

  defp process_commands(register, cpu) do
    {commands, new_cpu} =
      case :queue.out(cpu) do
        {:empty, new_cpu} ->
          {[], new_cpu}

        {{:value, {0, :eof}}, _new_cpu} ->
          {[], :eof}

        {{:value, {0, command}}, new_cpu} ->
          {[command], new_cpu}

        {{:value, {exec_time, command}}, new_cpu} when exec_time > 0 ->
          {[], :queue.in_r({exec_time - 1, command}, new_cpu)}
      end

    new_register =
      Enum.reduce(commands, register, fn
        :noop, register ->
          register

        {:addx, value}, register ->
          register + value
      end)

    {new_register, new_cpu}
  end

  defp add_command(cpu, command) do
    case command do
      {:addx, _value} = command ->
        :queue.in({1, command}, cpu)

      command ->
        :queue.in({0, command}, cpu)
    end
  end
end

"./input.txt" |> File.stream!() |> Day10.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day10.part02() |> IO.inspect(label: "part 2")

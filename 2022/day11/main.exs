defmodule Day11 do
  @operator_mappings %{"*" => &Kernel.*/2, "+" => &Kernel.+/2}

  def part01(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.reduce(%{monkeys: %{}, last_id: nil}, fn
      {:begin_monkey, id}, state ->
        state
        |> put_in([:monkeys, id], %{inspected_items: 0})
        |> put_in([:last_id], id)

      {:starting_items, starting_items}, state ->
        put_in(state, [:monkeys, state.last_id, :items], starting_items)

      {:operation, function}, state ->
        put_in(state, [:monkeys, state.last_id, :operation], function)

      {:test, function}, state ->
        put_in(state, [:monkeys, state.last_id, :test], function)

      {:if_true, function}, state ->
        put_in(state, [:monkeys, state.last_id, :if_true], function)

      {:if_false, function}, state ->
        put_in(state, [:monkeys, state.last_id, :if_false], function)

      :end_monkey, state ->
        state
    end)
    |> observe_monkeys(20)
    |> calculate_monkey_business()
  end

  def parse_line(line) do
    case line do
      "Monkey " <> rest ->
        case Integer.parse(rest) do
          {monkey_id, ":"} ->
            {:begin_monkey, monkey_id}
        end

      "Starting items: " <> rest ->
        {:starting_items,
         rest
         |> Stream.unfold(fn list ->
           case Integer.parse(list) do
             {item, ""} ->
               {item, ""}

             {item, ", " <> rest} ->
               {item, rest}

             :error ->
               nil
           end
         end)
         |> Enum.to_list()
         |> :queue.from_list()}

      "Operation: " <> rest ->
        case rest do
          "new = old " <> <<operation::binary-size(1), ?\s>> <> value ->
            rhs_function =
              case value do
                "old" ->
                  fn old -> old end

                other ->
                  integer = String.to_integer(other)
                  fn _ -> integer end
              end

            operator = Map.fetch!(@operator_mappings, operation)

            {:operation, fn old -> operator.(old, rhs_function.(old)) end}
        end

      "Test: " <> rest ->
        case rest do
          "divisible by " <> value ->
            integer = String.to_integer(value)
            {:test, &(rem(&1, integer) == 0)}
        end

      "If true: throw to monkey " <> rest ->
        case Integer.parse(rest) do
          {monkey_id, ""} ->
            {:if_true, throw_to(monkey_id)}
        end

      "If false: throw to monkey " <> rest ->
        case Integer.parse(rest) do
          {monkey_id, ""} ->
            {:if_false, throw_to(monkey_id)}
        end

      "" ->
        :end_monkey
    end
  end

  def part02(input) do
    input
  end

  defp throw_to(monkey_id) do
    fn state, item ->
      monkey = Map.fetch!(state.monkeys, monkey_id)
      items = :queue.in(item, monkey.items)
      put_in(state, [:monkeys, monkey_id, :items], items)
    end
  end

  defp observe_monkeys(state, rounds_left)

  defp observe_monkeys(state, 0) do
    state
  end

  defp observe_monkeys(state, rounds_left) when rounds_left > 0 do
    0..state.last_id
    |> Enum.reduce(state, &observe_round/2)
    |> observe_monkeys(rounds_left - 1)
  end

  defp observe_round(monkey_id, state) do
    monkey = Map.fetch!(state.monkeys, monkey_id)

    monkey.items
    |> :queue.to_list()
    |> Enum.reduce(state, fn item, state ->
      new_worry = item |> monkey.operation.() |> div(3)

      if monkey.test.(new_worry) do
        monkey.if_true.(state, new_worry)
      else
        monkey.if_false.(state, new_worry)
      end
      |> update_in([:monkeys, monkey_id, :inspected_items], &(&1 + 1))
    end)
    |> put_in([:monkeys, monkey_id, :items], :queue.new())
  end

  defp calculate_monkey_business(state) do
    state.monkeys
    |> Map.values()
    |> Enum.sort_by(& &1.inspected_items, :desc)
    |> Enum.take(2)
    |> Enum.map(& &1.inspected_items)
    |> Enum.product()
  end
end

"./input.txt" |> File.stream!() |> Day11.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day11.part02() |> IO.inspect(label: "part 2")

defmodule Day11 do
  @arithmetic_operator_mappings %{"*" => &Kernel.*/2, "+" => &Kernel.+/2}

  def part01(input) do
    input
    |> create_state()
    |> observe_monkeys(20, &div(&1, 3))
    |> calculate_monkey_business()
  end

  def part02(input) do
    input
    |> create_state()
    |> observe_monkeys(10000, &Function.identity/1)
    |> calculate_monkey_business()
  end

  defp create_state(input) do
    input
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.reduce(%{constant: 1, monkeys: %{}, last_id: nil}, fn
      {:begin_monkey, id}, state ->
        state
        |> put_in([:monkeys, id], %{inspected_items: 0})
        |> put_in([:last_id], id)

      {:starting_items, starting_items}, state ->
        put_in(state, [:monkeys, state.last_id, :items], starting_items)

      {:operation, function}, state ->
        put_in(state, [:monkeys, state.last_id, :operation], function)

      {:test, integer, function}, state ->
        state
        |> put_in([:monkeys, state.last_id, :test], function)
        |> update_in([:constant], &(&1 * integer))

      {:if_true, function}, state ->
        put_in(state, [:monkeys, state.last_id, :if_true], function)

      {:if_false, function}, state ->
        put_in(state, [:monkeys, state.last_id, :if_false], function)

      :end_monkey, state ->
        state
    end)
  end

  defp parse_line(line) do
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

            operator = Map.fetch!(@arithmetic_operator_mappings, operation)

            {:operation, fn old -> operator.(old, rhs_function.(old)) end}
        end

      "Test: " <> rest ->
        case rest do
          "divisible by " <> value ->
            integer = String.to_integer(value)

            {:test, integer,
             fn worry, constant ->
               new_worry = worry - div(worry, constant) * constant
               {new_worry, rem(new_worry, integer)}
             end}
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

  defp throw_to(monkey_id) do
    fn state, item ->
      monkey = Map.fetch!(state.monkeys, monkey_id)
      items = :queue.in(item, monkey.items)
      put_in(state, [:monkeys, monkey_id, :items], items)
    end
  end

  def observe_monkeys(state, rounds_left, post_inspection)

  def observe_monkeys(state, 0, _post_inspection) do
    state
  end

  def observe_monkeys(state, rounds_left, post_inspection) when rounds_left > 0 do
    0..state.last_id
    |> Enum.reduce(state, &observe_round(&1, &2, post_inspection))
    |> observe_monkeys(rounds_left - 1, post_inspection)
  end

  defp observe_round(monkey_id, state, post_inspection) do
    monkey = Map.fetch!(state.monkeys, monkey_id)

    monkey.items
    |> :queue.to_list()
    |> Enum.reduce(state, fn item, state ->
      new_worry = item |> monkey.operation.() |> post_inspection.()

      {reduced_worry, remainder} = monkey.test.(new_worry, state.constant)

      if remainder == 0 do
        monkey.if_true.(state, reduced_worry)
      else
        monkey.if_false.(state, reduced_worry)
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
"./input.txt" |> File.stream!() |> Day11.part02() |> IO.inspect(label: "part 2")

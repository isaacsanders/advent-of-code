defmodule Day07 do
  def part01(input) do
    initial_state = %{cwd: nil, tree: %{}}

    state =
      input
      |> Stream.map(&String.trim/1)
      |> Enum.reduce(initial_state, fn line, state ->
        line
        |> parse
        |> modify(state)
      end)

    state.tree
    |> dirs()
    |> Enum.map(&(state.tree |> get_in(&1) |> files_for_dir()))
    |> Enum.filter(fn files ->
      files |> Enum.map(fn {_filename, size} -> size end) |> Enum.sum() <= 100_000
    end)
    |> Enum.map(fn files ->
      files |> Enum.map(fn {_filename, size} -> size end) |> Enum.sum()
    end)
    |> Enum.sum()

    # state.tree
    # |> Enum.filter(fn {_file, size} -> size <= 100_000 end)
    # |> Enum.map(fn {_file, size} -> size end)
    # |> Enum.sum()
  end

  # def part02(input) do
  # end

  defp parse(line) do
    case line do
      "$ cd " <> dir ->
        {:cd, dir}

      "$ ls" ->
        :ls

      "dir " <> dirname ->
        {:add_dir, dirname}

      other ->
        case Integer.parse(other) do
          {size, " " <> filename} ->
            {:add_file, filename, size}

          :error ->
            IO.inspect(line)
        end
    end
  end

  defp modify(action, state) do
    case {action, state} do
      {{:cd, dir}, %{cwd: nil}} ->
        %{state | cwd: dir}

      {{:cd, dir}, state} ->
        %{state | cwd: state.cwd |> Path.join(dir) |> Path.expand()}

      {:ls, _state} ->
        state

      {{:add_file, filename, size}, state} ->
        %{state | tree: put_at(state.tree, state.cwd, filename, size)}

      {{:add_dir, dirname}, state} ->
        %{state | tree: put_at(state.tree, state.cwd, dirname, %{})}
    end
  end

  defp put_at(tree, cwd, leaf, value) do
    put_in(tree, (cwd |> Path.split() |> Enum.map(&Access.key(&1, %{}))) ++ [leaf], value)
  end

  defp dirs(tree, path \\ [])

  defp dirs(tree, []) do
    tree
    |> Enum.filter(fn {_name, value} -> is_map(value) end)
    |> Enum.flat_map(fn {dirname, listings} ->
      dirs(listings, [dirname])
    end)
  end

  defp dirs(tree, path) do
    subdirs =
      tree
      |> Enum.filter(fn {_name, value} -> is_map(value) end)
      |> Enum.flat_map(fn {dirname, listings} ->
        dirs(listings, path ++ [dirname])
      end)

    [path | subdirs]
  end

  defp files_for_dir(tree, files \\ []) do
    data =
      Enum.group_by(
        tree,
        fn
          {_dirname, subtree} when is_map(subtree) ->
            :directories

          {_filename, size} when is_integer(size) ->
            :files
        end,
        fn
          {_dirname, subtree} when is_map(subtree) ->
            subtree

          {filename, size} when is_integer(size) ->
            {filename, size}
        end
      )

    data
    |> Map.get(:directories, [])
    |> Enum.reduce(Map.get(data, :files, []) ++ files, fn subtree, files ->
      files_for_dir(subtree, files)
    end)
  end
end

"./input.txt" |> File.stream!() |> Day07.part01() |> IO.inspect(label: "part 1")
# "./input.txt" |> File.stream!() |> Day07.part02() |> IO.inspect(label: "part 2")

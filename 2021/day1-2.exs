{_last_item, count} =
  File.stream!("./inputs/day1.txt", [], :line)
  |> Enum.reduce({[], 0}, fn i, {stack, count} ->
    {num, _remained} = i |> Integer.parse()

    case length(stack) do
      3 ->
        pre_item = Enum.at(stack, 2)
        new_count = if num > pre_item, do: count + 1, else: count
        {[num | Enum.take(stack, 2)], new_count}

      _ ->
        {[num | stack], count}
    end
  end)

IO.puts(count)

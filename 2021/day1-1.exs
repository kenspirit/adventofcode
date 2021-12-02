{_last_item, count} =
  File.stream!("./inputs/day1.txt", [], :line)
  |> Enum.reduce({0, -1}, fn i, {pre_item, count} ->
    {num, _remained} = i |> Integer.parse()
    if num > pre_item, do: {num, count + 1}, else: {num, count}
  end)

IO.puts(count)

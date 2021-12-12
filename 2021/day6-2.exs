# --- Part Two ---
# Suppose the lanternfish live forever and have unlimited food and space.
# Would they take over the entire ocean?

# After 256 days in the example above, there would be a total of 26984457539 lanternfish!

# How many lanternfish would there be after 256 days?
defmodule Lanternfish do
  defp next_day({prev0, prev1, prev2, prev3, prev4, prev5, prev6, prev7, prev8}) do
    # If the fishes are at day prev0, which means its internal timer is 0,
    # when next day comes, it changes to 6 and so prev0 plus existing count at prev7,
    # also, each fish at day prev0 will spawn a new fish at day prev8.
    {prev1, prev2, prev3, prev4, prev5, prev6, prev7 + prev0, prev8, prev0}
  end

  def growth_pattern(initial_state, days) do
    fishes_count_at_each_day = Enum.frequencies(initial_state)

    initial_state_at_first_day =
      Enum.map(0..8, fn i -> fishes_count_at_each_day[i] || 0 end)
      |> List.to_tuple()

    1..days
    |> Enum.reduce(initial_state_at_first_day, fn _day, acc ->
      next_day(acc)
    end)
    |> Tuple.sum()
  end
end

File.read!("./inputs/day6.txt")
|> String.replace_trailing("\n", "")
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> Lanternfish.growth_pattern(256)
|> IO.puts()

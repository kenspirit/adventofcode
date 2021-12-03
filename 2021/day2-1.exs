defmodule Submarine do
  defp get_step(step) do
    {num, _remained} = step |> Integer.parse()
    num
  end

  defp process_step(<<"forward ", step::binary>>, {horizontal, depth}) do
    {horizontal + get_step(step), depth}
  end

  defp process_step(<<"up ", step::binary>>, {horizontal, depth}) do
    {horizontal, depth - get_step(step)}
  end

  defp process_step(<<"down ", step::binary>>, {horizontal, depth}) do
    {horizontal, depth + get_step(step)}
  end

  def calculate_position(instructions) do
    {horizontal, depth} = File.stream!(instructions, [], :line)
    |> Enum.reduce({0, 0}, &process_step/2)

    horizontal * depth
  end
end

IO.puts Submarine.calculate_position("./inputs/day2.txt")

defmodule Submarine do
  defp get_step(step) do
    {num, _remained} = step |> Integer.parse()
    num
  end

  defp process_step(<<"forward ", step::binary>>, {horizontal, depth, aim}) do
    step_num = get_step(step)
    {horizontal + step_num, depth + aim * step_num, aim}
  end

  defp process_step(<<"up ", step::binary>>, {horizontal, depth, aim}) do
    step_num = get_step(step)
    {horizontal, depth, aim - step_num}
  end

  defp process_step(<<"down ", step::binary>>, {horizontal, depth, aim}) do
    step_num = get_step(step)
    {horizontal, depth, aim + step_num}
  end

  def calculate_position(instructions) do
    {horizontal, depth, _aim} = File.stream!(instructions, [], :line)
    |> Enum.reduce({0, 0, 0}, &process_step/2)

    horizontal * depth
  end
end

IO.puts Submarine.calculate_position("./inputs/day2.txt")

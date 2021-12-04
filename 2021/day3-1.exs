defmodule BinaryDiagnostic do
  defp get_bit(?0) do
    -1
  end

  defp get_bit(?1) do
    1
  end

  defp parse_bits(diagnostic_result) do
    diagnostic_result
    |> String.replace("\n", "")
    |> to_charlist()
    |> Enum.map(&get_bit/1)
  end

  defp process_result(diagnostic_result, []) do
    parse_bits(diagnostic_result)
  end

  defp process_result(diagnostic_result, accumulated_results) do
    current_result = parse_bits(diagnostic_result)

    result =
      Enum.zip_with(current_result, accumulated_results, fn bit1, bit2 ->
        bit1 + bit2
      end)
  end

  def calculate_consumption(diagnostic_results) do
    final_results =
      File.stream!(diagnostic_results, [], :line)
      |> Enum.reduce([], &process_result/2)

    {gamma, _} =
      final_results
      |> Enum.map(fn bit ->
        if bit > 0, do: 1, else: 0
      end)
      |> Enum.join()
      |> Integer.parse(2)

    {epsilon, _} =
      final_results
      |> Enum.map(fn bit ->
        if bit > 0, do: 0, else: 1
      end)
      |> Enum.join()
      |> Integer.parse(2)

    gamma * epsilon
  end
end

IO.puts(BinaryDiagnostic.calculate_consumption("./inputs/day3.txt"))

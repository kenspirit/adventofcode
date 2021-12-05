defmodule BinaryDiagnostic do
  defp get_bit(?0) do
    0
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

  defp process_result([], {_pos, [final_result], []}, _any) do
    final_result
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end

  defp process_result([], {_pos, [], [final_result]}, _any) do
    final_result
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end

  defp process_result([], {pos, result_with_1bits, result_with_0bits}, :most) do
    if length(result_with_1bits) >= length(result_with_0bits) do
      process_result(result_with_1bits, {pos + 1, [], []}, :most)
    else
      process_result(result_with_0bits, {pos + 1, [], []}, :most)
    end
  end

  defp process_result([], {pos, result_with_1bits, result_with_0bits}, :least) do
    if length(result_with_1bits) >= length(result_with_0bits) do
      process_result(result_with_0bits, {pos + 1, [], []}, :least)
    else
      process_result(result_with_1bits, {pos + 1, [], []}, :least)
    end
  end

  defp process_result([], {0, result_with_1bits, result_with_0bits}, :first) do
    # First Categoried by most / least bit is done.
    # Always get the most bit part
    oxygen_rating =
      if length(result_with_1bits) >= length(result_with_0bits) do
        process_result(result_with_1bits, {1, [], []}, :most)
      else
        process_result(result_with_0bits, {1, [], []}, :most)
      end

    # Always get the least bit part
    co2_rating =
      if length(result_with_1bits) >= length(result_with_0bits) do
        process_result(result_with_0bits, {1, [], []}, :least)
      else
        process_result(result_with_1bits, {1, [], []}, :least)
      end

    {oxygen_rating, co2_rating}
  end

  defp process_result(
         [diagnostic_result | remained],
         {pos, result_with_1bits, result_with_0bits},
         any
       ) do
    bit_at_pos = Enum.at(diagnostic_result, pos)

    if bit_at_pos == 1 do
      process_result(
        remained,
        {pos, [diagnostic_result | result_with_1bits], result_with_0bits},
        any
      )
    else
      process_result(
        remained,
        {pos, result_with_1bits, [diagnostic_result | result_with_0bits]},
        any
      )
    end
  end

  def calculate_rating(diagnostic_results) do
    {oxygen_rating, co2_rating} =
      File.stream!(diagnostic_results, [], :line)
      |> Enum.map(&parse_bits/1)
      |> process_result({0, [], []}, :first)

    oxygen_rating * co2_rating
  end
end

IO.puts(BinaryDiagnostic.calculate_rating("./inputs/day3.txt"))

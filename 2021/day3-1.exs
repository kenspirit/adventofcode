"""
--- Day 3: Binary Diagnostic ---
The submarine has been making some odd creaking noises, so you ask it to produce a diagnostic report just in case.

The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine.
The first parameter to check is the power consumption.

You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the gamma rate and the epsilon rate).
The power consumption can then be found by multiplying the gamma rate by the epsilon rate.

Each bit in the gamma rate can be determined by finding the most common bit in the corresponding position of all numbers in the diagnostic report.
For example, given the following diagnostic report:

00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010

Considering only the first bit of each number, there are five 0 bits and seven 1 bits.
Since the most common bit is 1, the first bit of the gamma rate is 1.

The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.

The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.

So, the gamma rate is the binary number 10110, or 22 in decimal.

The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used.
So, the epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, 198.

Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together.
What is the power consumption of the submarine? (Be sure to represent your answer in decimal, not binary.)
"""

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

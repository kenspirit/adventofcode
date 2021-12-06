# --- Day 4: Giant Squid ---
# You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight.
# What you can see, however, is a giant squid that has attached itself to the outside of your submarine.

# Maybe it wants to play bingo?

# Bingo is played on a set of boards each consisting of a 5x5 grid of numbers.
# Numbers are chosen at random, and the chosen number is marked on all boards on which it appears.
# (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board wins.
# (Diagonals don't count.)

# The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass the time.
# It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input).

# For example:
# 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

# 22 13 17 11  0
#  8  2 23  4 24
# 21  9 14 16  7
#  6 10  3 18  5
#  1 12 20 15 19

#  3 15  0  2 22
#  9 18 13 17  5
# 19  8  7 25 23
# 20 11 10 24  4
# 14 21 16 12  6

# 14 21 17 24  4
# 10 16 15  9 19
# 18  8 23 26 20
# 22 11 13  6  5
#  2  0 12  3  7

# After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners,
# but the boards are marked as follows (shown here adjacent to each other to save space):

# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

# After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:

# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

# Finally, 24 is drawn:

# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

# At this point, the third board wins because it has at least one complete row or column of marked numbers
# (in this case, the entire top row is marked: 14 21 17 24 4).

# The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board;
# in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won, 24,
# to get the final score, 188 * 24 = 4512.

# To guarantee victory against the giant squid, figure out which board will win first.
# What will your final score be if you choose that board?
defmodule Bingo do
  defp parse_board_line(line) do
    String.split(line, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp add_line_to_boards([], line) do
    [parse_board_line(line)]
  end

  defp add_line_to_boards([board | others], line) when length(board) == 25 do
    all_boards = [board | others]
    [parse_board_line(line) | all_boards]
  end

  defp add_line_to_boards([board | others], line) do
    [Enum.concat(board, parse_board_line(line)) | others]
  end

  defp prepare_drawn_and_boards([], drawn, boards) do
    {drawn, boards}
  end

  defp prepare_drawn_and_boards([line | remained], drawn, boards) do
    cond do
      String.contains?(line, ",") ->
        drawn =
          line
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)

        prepare_drawn_and_boards(remained, drawn, boards)

      line == "" ->
        prepare_drawn_and_boards(remained, drawn, boards)

      true ->
        prepare_drawn_and_boards(remained, drawn, add_line_to_boards(boards, line))
    end
  end

  defp mark_drawn_on_boards(drawn, boards) do
    Enum.map(boards, fn board ->
      Enum.map(board, fn num ->
        if num == drawn, do: 0, else: num
      end)
    end)
  end

  defp check_each_draw([], boards, _drawn_count) do
    boards
  end

  defp check_each_draw([drawn | remained], boards, drawn_count) when drawn_count < 4 do
    board_marked = mark_drawn_on_boards(drawn, boards)

    check_each_draw(remained, board_marked, drawn_count + 1)
  end

  defp check_each_draw([drawn | remained], boards, drawn_count) do
    board_marked = mark_drawn_on_boards(drawn, boards)
    board_bingoed = check_bingo_on_boards(board_marked)

    case board_bingoed do
      nil ->
        check_each_draw(remained, board_marked, drawn_count + 1)

      _ ->
        IO.inspect("======= Bingo on draw number #{drawn} =======")
        IO.inspect(board_bingoed)
        drawn * Enum.sum(board_bingoed)
    end
  end

  defp check_bingo_on_boards(boards) do
    Enum.find_value(boards, fn board ->
      if any_row_bingo(board) || any_column_bingo(board), do: board, else: nil
    end)
  end

  defp any_row_bingo(board) do
    Enum.chunk_every(board, 5)
    |> Enum.any?(fn row ->
      Enum.sum(row) == 0
    end)
  end

  defp any_column_bingo(board) do
    Enum.any?(0..4, fn col ->
      Enum.map(0..4, fn row ->
        Enum.at(board, row * 5 + col)
      end)
      |> Enum.sum() == 0
    end)
  end

  def find_board(diagnostic_results) do
    {drawn, boards} =
      File.stream!(diagnostic_results, [], :line)
      |> Enum.map(&String.replace(&1, "\n", ""))
      |> prepare_drawn_and_boards([], [])

    IO.puts("Draws:")
    IO.inspect(drawn)

    IO.puts("Boards:")

    boards
    |> Enum.each(&IO.inspect/1)

    board = check_each_draw(drawn, boards, 0)

    if board == nil do
      IO.puts("No single board has a winning combination.")
    else
      IO.inspect(board)
    end
  end
end

Bingo.find_board("./inputs/day4.txt")

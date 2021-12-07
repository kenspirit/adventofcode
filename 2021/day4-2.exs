# --- Part Two ---
# On the other hand, it might be wise to try a different strategy: let the giant squid win.

# You aren't sure how many bingo boards a giant squid could play at once, so rather than waste time counting its arms,
# the safe thing to do is to figure out which board will win last and choose that one.
# That way, no matter which boards it picks, it will win for sure.

# In the above example, the second board is the last to win, which happens after 13 is eventually called and its middle column is completely marked.
# If you were to keep playing until this point, the second board would have a sum of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.

# Figure out which board will win last. Once it wins, what would its final score be?
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

  defp get_last_win_board([], _boards, [], _drawn_index) do
    -1
  end

  defp get_last_win_board([], _boards, [{last_win, drawn} | remained], _drawn_index) do
    drawn * Enum.sum(last_win)
  end

  defp get_last_win_board(_drawns, _boards, bingoed_boards, drawn_index)
       when length(bingoed_boards) == drawn_index + 1 do
    [{last_win, drawn} | others] = bingoed_boards
    drawn * Enum.sum(last_win)
  end

  defp get_last_win_board([drawn | remained], boards, bingoed_boards, drawn_index)
       when drawn_index < 4 do
    marked_boards = mark_drawn_on_boards(drawn, boards)

    get_last_win_board(remained, marked_boards, bingoed_boards, drawn_index + 1)
  end

  defp get_last_win_board([drawn | remained], boards, bingoed_boards, drawn_index) do
    marked_boards = mark_drawn_on_boards(drawn, boards)
    {un_bingoed_boards, new_bingoed_boards} = separate_boards(marked_boards, drawn)

    get_last_win_board(
      remained,
      un_bingoed_boards,
      Enum.concat(new_bingoed_boards, bingoed_boards),
      drawn_index + 1
    )
  end

  defp separate_boards(boards, drawn) do
    Enum.reduce(boards, {[], []}, fn board, {un_bingoed_boards, new_bingoed_boards} ->
      if any_row_bingo(board) || any_column_bingo(board) do
        {un_bingoed_boards, [{board, drawn} | new_bingoed_boards]}
      else
        {Enum.concat(un_bingoed_boards, [board]), new_bingoed_boards}
      end
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

    board = get_last_win_board(drawn, boards, [], 0)

    if board == -1 do
      IO.puts("No single board has a winning combination.")
    else
      IO.inspect(board)
    end
  end
end

Bingo.find_board("./inputs/day4.txt")

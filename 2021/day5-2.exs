# --- Part Two ---
# Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture;
# you need to also consider diagonal lines.

# Because of the limits of the hydrothermal vent mapping system, the lines in your list will only ever be horizontal, vertical, or a diagonal line at exactly 45 degrees.
# In other words:

# An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
# An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
# Considering all lines from the above example would now produce the following diagram:

# 1.1....11.
# .111...2..
# ..2.1.111.
# ...1.2.2..
# .112313211
# ...1.2....
# ..1...1...
# .1.....1..
# 1.......1.
# 222111....

# You still need to determine the number of points where at least two lines overlap.
# In the above example, this is still anywhere in the diagram with a 2 or larger - now a total of 12 points.

# Consider all of the lines. At how many points do at least two lines overlap?

defmodule HydrothermalVenture do
  defp parse_coordinates(line_segment) do
    line_segment
    |> String.replace("\n", "")
    |> String.split(" -> ")
    |> Enum.map(fn coordinate ->
      [x, y] = String.split(coordinate, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  # Vertical line
  defp line_met_criteria([{x1, _y1}, {x2, _y2}]) when x1 == x2 do
    true
  end

  # Horizontal line
  defp line_met_criteria([{_x1, y1}, {_x2, y2}]) when y1 == y2 do
    true
  end

  # Upward/Downward 45-degree line or others
  defp line_met_criteria([{x1, y1}, {x2, y2}]) do
    abs(x1 - y1) == abs(x2 - y2) or abs(x1 - x2) == abs(y1 - y2)
  end

  defp keep_only_horizontal_vertical_or_diagonal_at_45_degree_lines(coordinates) do
    Enum.filter(coordinates, &line_met_criteria/1)
  end

  defp rearrange([{x1, y1}, {x2, y2}]) when x1 == x2 and y1 > y2 do
    [{x1, y2}, {x2, y1}]
  end

  defp rearrange([{x1, y1}, {x2, y2}]) when y1 == y2 and x1 > x2 do
    [{x2, y1}, {x1, y2}]
  end

  defp rearrange([{x1, y1}, {x2, y2}]) when x1 > x2 do
    [{x2, y2}, {x1, y1}]
  end

  defp rearrange(coordinate), do: coordinate

  defp rearrange_positions(coordinates) do
    Enum.map(coordinates, &rearrange/1)
  end

  defp mark_point_on_board([{x1, y1}, {x2, y2}], board) when x1 == x2 do
    Enum.reduce(y1..y2, board, fn y, board ->
      mark_point_on_board(x1, y, board)
    end)
  end

  defp mark_point_on_board([{x1, y1}, {x2, y2}], board) when y1 == y2 do
    Enum.reduce(x1..x2, board, fn x, board ->
      mark_point_on_board(x, y1, board)
    end)
  end

  # Upward 45-degree line
  defp mark_point_on_board([{x1, y1}, {_x2, y2}], board) when y1 < y2 do
    diff = y2 - y1
    Enum.reduce(0..diff, board, fn step, board ->
      mark_point_on_board(x1 + step, y1 + step, board)
    end)
  end

  # Downward 45-degree line
  defp mark_point_on_board([{x1, y1}, {_x2, y2}], board) do
    diff = abs(y2 - y1)
    Enum.reduce(0..diff, board, fn step, board ->
      mark_point_on_board(x1 + step, y1 - step, board)
    end)
  end

  defp mark_point_on_board(x, y, board) do
    Map.update(board, {x, y}, 1, fn v -> v + 1 end)
  end

  defp mark_points_on_board([], board) do
    board
  end

  defp mark_points_on_board([segment | others], board) do
    mark_points_on_board(others, mark_point_on_board(segment, board))
  end

  def find_vents(vents) do
    File.stream!(vents, [], :line)
    |> Enum.map(&parse_coordinates/1)
    |> keep_only_horizontal_vertical_or_diagonal_at_45_degree_lines()
    |> rearrange_positions()
    # |> tap(&IO.inspect/1)
    |> mark_points_on_board(%{})
    |> Map.values()
    |> Enum.filter(fn v -> v > 1 end)
    |> length()
    |> IO.puts()
  end
end

HydrothermalVenture.find_vents("./inputs/day5.txt")

# --- Day 5: Hydrothermal Venture ---
# You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

# They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

# 0,9 -> 5,9
# 8,0 -> 0,8
# 9,4 -> 3,4
# 2,2 -> 2,1
# 7,0 -> 7,4
# 6,4 -> 2,0
# 0,9 -> 2,9
# 3,4 -> 1,4
# 0,0 -> 8,8
# 5,5 -> 8,2

# Each line of vents is given as a line segment in the format x1,y1 -> x2,y2
# where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end.
# These line segments include the points at both ends. In other words:

# An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
# An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
# For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

# So, the horizontal and vertical lines from the above list would produce the following diagram:

# .......1..
# ..1....1..
# ..1....1..
# .......1..
# .112111211
# ..........
# ..........
# ..........
# ..........
# 222111....

# In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9.
# Each position is shown as the number of lines which cover that point or . if no line covers that point.
# The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

# To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap.
# In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

# Consider only horizontal and vertical lines. At how many points do at least two lines overlap?
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

  defp keep_only_horizontal_and_vertical_lines(coordinates) do
    coordinates
    |> Enum.filter(fn [{x1, y1}, {x2, y2}] ->
      x1 == x2 or y1 == y2
    end)
  end

  defp rearrange([{x1, y1}, {x2, y2}]) when x1 == x2 and y1 > y2 do
    [{x1, y2}, {x2, y1}]
  end

  defp rearrange([{x1, y1}, {x2, y2}]) when y1 == y2 and x1 > x2 do
    [{x2, y1}, {x1, y2}]
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
    |> keep_only_horizontal_and_vertical_lines()
    |> rearrange_positions()
    |> mark_points_on_board(%{})
    |> Map.values()
    |> Enum.filter(fn v -> v > 1 end)
    |> length()
    |> IO.puts()
  end
end

HydrothermalVenture.find_vents("./inputs/day5.txt")

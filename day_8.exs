
defmodule DayHelper do
  def paint_map(map, antinodes) do
    antinodes
    |> Enum.reduce(map, fn {i, j}, acc ->
        tile = Enum.at(map, i) |> Enum.at(j)
        if tile != "." do
          acc
        else
          DayHelper.paint_tile(acc, i, j)
        end
    end)
  end

  def paint_tile(map, line_index, tile_index) do
    new_line = Enum.at(map, line_index) |> List.replace_at(tile_index, "#")


    List.replace_at(map, line_index, new_line)
  end

  def process_magnitude({i, j}, oi, oj, xi, xj, upper_bound, right_bound, acc) do
    new_antinode = {i + (oi - xi), j + (oj - xj)}
    {ni, nj} = new_antinode

    if ni < 0 || ni > upper_bound || nj < 0 || nj > right_bound do
      acc
    else
      process_magnitude(new_antinode, oi, oj, xi, xj, upper_bound, right_bound, [new_antinode | acc ])
    end

  end
end

map = File.read!("inputs/input_day8.txt")
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes(&1))

uniqe_values = map
|> List.flatten()
|> Enum.uniq()
|> Enum.reject(fn x -> x == "." end)
|> Enum.map(fn x -> {x, []} end)

coordinates = map
|> Enum.map(fn x -> Enum.with_index(x) end)
|> Enum.with_index()

antennas = uniqe_values
|> Enum.map(fn {v, _} ->
    v_coordinates = Enum.reduce(coordinates, [], fn {x, i}, acc ->
      Enum.reduce(x, acc , fn { g, j }, acc2 ->
        if g == v do
          [{i, j} | acc2]
        else
          acc2
        end
      end)
    end)
    {v, v_coordinates |> Enum.reverse()}
end)

upper_bound = length(map) - 1
right_bound = (map |> Enum.at(0) |> length()) - 1

map_locations = antennas
|> Enum.map(fn {antenna, coordinates} ->
   antinodes = Enum.map(coordinates, fn {i, j} ->
      Enum.map(coordinates, fn {xi, xj} ->
        if i == xi and j == xj do
          {}
        else
          na = {i + (i - xi) ,j + ( j - xj )}
          DayHelper.process_magnitude(na, i, j, xi, xj, upper_bound, right_bound, [na])
        end
      end)
    end)
    |> List.flatten
    |> Enum.reject(fn x -> tuple_size(x) == 0 end)
    |> Enum.reject(fn {i, j} -> i < 0 || i > upper_bound || j < 0 || j > right_bound end)

    %{antenna: antenna, coordinates: coordinates, antinodes: antinodes}
end)

map_locations
|> Enum.reduce(map, fn m, acc ->
    DayHelper.paint_map(acc, m[:antinodes])
end)

map_locations
|> Enum.reduce([], fn m, acc ->
    m[:antinodes] ++ acc ++ m[:coordinates]
end)
|> Enum.uniq()
|> length()
|> IO.inspect()

defmodule DayHelper do

  def find_guard(map) do
    found_line_index = map
    |>
    Enum.find_index(fn line -> Enum.any?(line, fn tile -> tile == "^" end) end)

    found_tile_index = Enum.at(map, found_line_index)
    |> Enum.find_index(fn tile -> tile == "^" end)

    {found_line_index, found_tile_index}
  end

  def move_guard(map, {line_index, tile_index}, direction, {upper_boundary, right_boundary} = boundary, last_steps) do
    map =  DayHelper.paint_tile(map, line_index, tile_index, "X")

    {new_line_index, new_tile_index} = next_line_tile(line_index, tile_index, direction)
    if new_line_index >= upper_boundary or new_tile_index >= right_boundary
    or new_line_index == -1 or new_tile_index == -1 do
      {:ok, map}
    else
      if last_steps == 15000 do
        {:loop, map}
      else
        DayHelper.next_move(map, direction, line_index, new_line_index, tile_index, new_tile_index, boundary, last_steps + 1)
      end
    end
  end

  def next_move(map, direction, line_index, new_line_index, tile_index, new_tile_index, boundary, last_steps) do
    tile = Enum.at(map, new_line_index) |> Enum.at(new_tile_index)
    new_direction = change_direction(tile, direction)

    {new_line_index, new_tile_index, new_direction} = if new_direction != direction do
       { nli2, nti2 } = next_line_tile(line_index, tile_index, new_direction)

       tile_2 = Enum.at(map, nli2) |> Enum.at(nti2)
       nd2 = change_direction(tile_2, new_direction)
       if nd2 != new_direction do
        {nli3, nti3} = next_line_tile(line_index, tile_index, nd2)
        {nli3, nti3, nd2}
       else
        { nli2, nti2, new_direction }
       end
    else
      {new_line_index, new_tile_index, direction}
    end

    new_map = DayHelper.paint_tile(map, new_line_index, new_tile_index, new_direction)
    DayHelper.move_guard(new_map, {new_line_index, new_tile_index}, new_direction, boundary, last_steps)
  end

  def paint_tile(map, line_index, tile_index, character) do
    new_line = Enum.at(map, line_index) |> List.replace_at(tile_index, character)
    List.replace_at(map, line_index, new_line)
  end

  def next_line_tile(line_index, tile_index, direction) do
    case direction do
      "^" -> {line_index - 1, tile_index}
      "v" -> {line_index + 1, tile_index}
      "<" -> {line_index    , tile_index - 1}
      ">" -> {line_index    , tile_index + 1}
    end
  end

  def change_direction(tile, direction) do
    case tile do
      "#" -> case direction do
              "^" -> ">"
              "v" -> "<"
              ">" -> "v"
              "<" -> "^"
            end
       _ -> direction
      end
  end
end

defmodule Day5 do

  def prepare_task do
    map = File.read!("inputs/input_day6.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)

    current_position = map
    |> DayHelper.find_guard()

    {map, current_position}
  end

  def task1_follow_the_guard do
    {map, current_position} = Day5.prepare_task

    upper_boundary = length(map)
    right_boundary = Enum.at(map, 0) |> length()

    DayHelper.move_guard(map, current_position, "^", {upper_boundary, right_boundary}, 0)
    |> elem(1)
    |> Enum.reduce(0, fn line, acc -> Enum.count(line, fn c -> c == "X" end) + acc end)
    |> IO.inspect()
    #5208
  end

  def task2_obstruct_the_guard do
    {map, current_position} = Day5.prepare_task

    upper_boundary = length(map)
    right_boundary = Enum.at(map, 0) |> length()

    Enum.map(0..(upper_boundary * right_boundary - 1), fn x ->
      line_index = trunc(x / upper_boundary)
      tile_index = x - right_boundary * line_index

      tile = Enum.at(map, line_index) |> Enum.at(tile_index)
      if tile == "#" || tile == "^" do
        Task.async(fn -> {:ok, []} end)
      else
        map = DayHelper.paint_tile(map, line_index, tile_index, "#")
        Task.async(fn -> DayHelper.move_guard(map, current_position, "^", {upper_boundary, right_boundary}, 0) end)
      end
    end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.count(fn {atom, _} -> atom == :loop end)
    |> IO.inspect()
    #1972
  end
end

Day5.task1_follow_the_guard
Day5.task2_obstruct_the_guard

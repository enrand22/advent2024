defmodule DayHelper do
  def fill_gaps(disk_map, first_index, taken_index) do
    {dot, first_empty_index} = get_first_index(disk_map, first_index)
    {tile, last_index} = get_last_index(disk_map, taken_index)

    if first_empty_index > last_index do
      disk_map
    else
      disk_map = %{disk_map | first_empty_index => tile}
      disk_map = %{disk_map | last_index => dot}

      DayHelper.fill_gaps(disk_map, first_empty_index, last_index)
    end
  end

  def get_last_index(disk_map, taken_index) do
    tile = Map.get(disk_map, taken_index)
    if tile == "." do
      get_last_index(disk_map, taken_index - 1)
    else
      {tile, taken_index}
    end
  end

  def get_first_index(disk_map, first_index) do
    tile = Map.get(disk_map, first_index)
    if tile == "." do
      {tile, first_index}
    else
      get_first_index(disk_map, first_index + 1)
    end
  end
end

disk_map = File.read!("inputs/input_day9.txt")
|> String.graphemes()
|> Enum.with_index()
|> Enum.reduce({0, []}, fn {x, i}, {p, acc} ->
    cond  do
      p == 0 -> {1, [ String.duplicate("0,", String.to_integer(x)) |> String.split(",", trim: true) | acc ]}
      rem(i, 2) != 0 -> { p, [ String.duplicate(".", String.to_integer(x)) |> String.graphemes() | acc] }
      true -> {p + 1, ["#{String.duplicate("#{p},",String.to_integer(x))}" |> String.split(",", trim: true)  | acc ]}
    end
end)
|> elem(1)
|> List.flatten()
|> Enum.reverse()
|> Enum.with_index()
|> Enum.map(fn {x, i} -> {i, x} end)
|> Enum.into(%{})

defrag = disk_map
|> DayHelper.fill_gaps(0, map_size(disk_map) - 1)

Enum.map(0..(map_size(defrag) - 1), fn i ->
  v = Map.get(defrag, i)

  if v == "." do
    0
  else
    String.to_integer(v) * i
  end
end)
|> Enum.sum()
|> IO.inspect()

#90119246415
#90119246419
#6299243228569

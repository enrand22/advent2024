
defmodule DayHelper do
  def split_numbers(line) do
    split = String.split(line)
    { String.to_integer(Enum.at(split, 0)), String.to_integer(Enum.at(split, 1)) }
  end
end

defmodule Day1 do
  def task1_find_total_distance(first_list, second_list) do
    first_list
    |> Enum.sort()
    |> Enum.with_index(fn element, index -> abs(element - Enum.at(second_list, index)) end)
    |> Enum.sum()
    |> IO.inspect
    # 2375403
  end

  def task2_find_similarity(first_list, second_list) do
    first_list
    |> Enum.map(fn f ->
      case Map.fetch(second_list, f) do
        {:ok, v } -> f * v
        :error    -> 0
      end
    end )
    |> Enum.sum()
    |> IO.inspect()
    #23082277
  end
end

{list1, list2} = File.read!("inputs/input_day1.txt")
|> String.split("\n", trim: true)
|> Enum.map(&DayHelper.split_numbers/1)
|> Enum.unzip

Day1.task1_find_total_distance(list1, list2 |> Enum.sort() )
Day1.task2_find_similarity(list1,     list2 |> Enum.frequencies() )

defmodule DayHelper do
  def calc_each_report( [ head | tail ] = report, dampness \\ false ) do
    distances = calc_distance(head, [], tail)

    test_signed_similarity(distances) && test_distance_threshold(distances) ||
    (dampness && re_test(report))
  end

  def re_test(original), do: re_test(0, original, false)

  def re_test(_index, _original, safeness) when safeness, do: true

  def re_test(index, original, _safeness) when index < length(original) do
    {_, new_report} = List.pop_at(original, index)
    re_test(index + 1, original, calc_each_report(new_report))
  end

  def re_test(_index, _original, _safeness), do: false

  def test_positivity(distances), do: Enum.all?(distances, fn x -> x >= 0 end)
  def test_negativity(distances), do: Enum.all?(distances, fn x -> x <= 0 end)

  def test_signed_similarity(distances) do
    if test_positivity(distances), do: true, else: test_negativity(distances)
  end

  def test_distance_threshold(distances) do
    Enum.map(distances, fn x -> abs(x) end)
    |> Enum.all?(fn x -> x >= 1 && x <= 3 end)
  end

  def calc_distance(past_value, new_list, [head | tail]) when length(tail) == 0 do
    [past_value - head | new_list ]
    |> Enum.reverse()
  end

  def calc_distance(past_value, new_list, [head | tail]) do
    calc_distance(head, [past_value - head | new_list ], tail)
  end

  def split_numbers(line) do
    String.split(line)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Day2 do
  def prepare_file() do
    File.read!("inputs/input_day2.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&DayHelper.split_numbers/1)
  end

  def task1_find_safeness do
    prepare_file()
    |> Enum.map(&DayHelper.calc_each_report/1)
    |> Enum.count(fn x -> x end)
    |> IO.inspect()
    #242
  end

  def task2_find_safeness_with_dampeness do
    prepare_file()
    |> Enum.map(&DayHelper.calc_each_report(&1, true))
    |> Enum.count(fn x -> x end)
    |> IO.inspect()
    #311
  end

end

Day2.task1_find_safeness
Day2.task2_find_safeness_with_dampeness

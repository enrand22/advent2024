defmodule DayHelper do
  def calc_each_report(report) do
    [head | tail ] = report

    distances = calc_distance(head, [], tail)

    all_positive = test_positivity(distances)
    all_negative = test_negativity(distances)

    if all_positive || all_negative do
      Enum.map(distances, fn x -> abs(x) end)
      |> Enum.all?(fn x -> x >= 1 && x <= 3 end)
    else
      false
    end
  end

  def calc_each_report_with_dampness(report, recalc \\ true) do
    [head | tail ] = report

    distances = calc_distance(head, [], tail)

    all_positive = test_positivity(distances)
    all_negative = test_negativity(distances)

    if all_positive || all_negative do
      result = Enum.map(distances, fn x -> abs(x) end)
      |> Enum.all?(fn x -> x >= 1 && x <= 3 end)

      if result do
        true
      else
         if recalc do
          re_test(0, Enum.count(report), report, false)
         else
          false
         end
      end
    else
      if recalc do
        re_test(0, Enum.count(report), report, false)
      else
        false
      end
    end
  end

  def re_test(_index, _length, _original, safeness) when safeness, do: true

  def re_test(index, length, original, _safeness) when index < length do
    {_, new_report} = List.pop_at(original, index)
    re_test(index + 1, length, original, calc_each_report_with_dampness(new_report, false ) )
  end

  def re_test(_index, _length, _original, _safeness), do: false

  def test_positivity(distances), do: Enum.all?(distances, fn x -> x >= 0 end)
  def test_negativity(distances), do: Enum.all?(distances, fn x -> x <= 0 end)

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
  def task1_find_safeness do
    File.read!("inputs/input_day2.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&DayHelper.split_numbers/1)
    |> Enum.map(&DayHelper.calc_each_report/1)
    |> Enum.count(fn x -> x end)
    |> IO.inspect()
    #242
  end

  def task2_find_safeness_with_dampeness do
    File.read!("inputs/input_day2.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&DayHelper.split_numbers/1)
    |> Enum.map(&DayHelper.calc_each_report_with_dampness/1)
    |> Enum.count(fn x -> x end)
    |> IO.inspect()
    #242
  end

end

Day2.task1_find_safeness
Day2.task2_find_safeness_with_dampeness

defmodule DayHelper do
  def split_numbers(line) do
    split = String.split(line, "|")
    { Enum.at(split, 0), Enum.at(split, 1) }
  end

  def find_line_in_manual(manual, upper_values) do
    manual
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.map(fn {line, index} ->
       if index == 0 do
        {false, line}
       else
        case Map.get(upper_values, line) do
          nil   -> {false, line}
          rule -> {manual
          |> Enum.slice(0..(index - 1))
          |> Enum.any?(fn x -> Enum.member?(rule, x) end), line }
        end
       end
    end)
  end

  def rules do
    rules = File.read!("inputs/input_day5p1.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&DayHelper.split_numbers/1)

    upper_values = rules
    |> Enum.uniq_by(fn {x, _} -> x end)
    |> Enum.map(fn {x, _} -> {x , []} end)
    |> Map.new()

    upper_values = rules
    |> Enum.reduce(upper_values, fn {x, y}, acc ->
        values = Map.get(acc, x)
        %{acc | x => [y | values]}
    end)

    upper_values
  end

  def manuals do
    File.read!("inputs/input_day5p2.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1,","))
  end

  def fix_manual(manual, rules) do
    {_, line} = manual
    |> Enum.reverse()
    |> Enum.find(fn {b, _} -> b end)

    fixed_manual = move_value(line, manual, rules)
    if Enum.all?(fixed_manual, fn {b, _} -> !b end) do
      fixed_manual
    else
      fix_manual(fixed_manual, rules)
    end
  end

  def move_value(line, manual, rules) do
    rule = Map.get(rules, line)
    original_manual = Keyword.values(manual)

    current_index = Enum.find_index(original_manual, fn x -> x == line end)
    min_index     = Enum.find_index(original_manual, fn x -> Enum.member?(rule, x)  end)

    { { _ , value}, list } = List.pop_at(manual, current_index)
    List.insert_at(list, min_index, {false, value})
  end


  def test_manual(manual) do
    manual
    |> Enum.reduce(0, fn t, acc ->
      if Enum.all?(t, fn {b, _} -> !b end) do
        line = Enum.at(t, trunc(length(t) / 2 - 0.5)) |> elem(1)
        acc + String.to_integer(line)
      else
        acc
      end
     end)
  end
end

defmodule Day5 do
  def task1_finding_correct_manuals do
    upper_values = DayHelper.rules

    DayHelper.manuals
    |> Enum.map(&DayHelper.find_line_in_manual(&1, upper_values))
    |> DayHelper.test_manual()
    |> IO.inspect()
  end

  def task2_fixing_wrong_manuals do
    upper_values = DayHelper.rules

    DayHelper.manuals
    |> Enum.map(&DayHelper.find_line_in_manual(&1, upper_values))
    |> Enum.reject(fn t -> Enum.all?(t, fn {b, _} -> !b end) end)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&DayHelper.fix_manual(&1, upper_values) |> Keyword.values())
    |> Enum.map(&DayHelper.find_line_in_manual(&1, upper_values))
    |> DayHelper.test_manual()
    |> IO.inspect()
  end
end

Day5.task1_finding_correct_manuals
Day5.task2_fixing_wrong_manuals

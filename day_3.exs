defmodule DayHelper do
  def find_values(operation) do
    if Regex.match?(~r/do\(\)|don't\(\)/, operation) do
      { operation }
    else
      finds = Regex.scan(~r/[\d]+/, operation)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

      { operation, finds}
    end
  end
end

defmodule Day3 do
  def task1_fixing_corrupted_data do
    input = File.read!("inputs/input_day3.txt")
    Regex.scan(~r/mul\([\d]+,[\d]+\)/, input)
    |> List.flatten()
    |> Enum.map(&DayHelper.find_values/1)
    |> Enum.map(fn {_, v} -> Enum.product(v) end)
    |> Enum.sum()
    |> IO.inspect()
    #170068701
  end

  def task2_fixing_corrupted_process do
    input = File.read!("inputs/input_day3.txt")
    Regex.scan(~r/mul\([\d]+,[\d]+\)|do\(\)|don't\(\)/, input)
    |> List.flatten()
    |> Enum.map(&DayHelper.find_values/1)
    |> Enum.reduce({"do()", 0}, fn x, {oper, v} ->
        if tuple_size(x) == 1 do
          {Kernel.elem( x , 0 ), v}
        else
          if oper == "do()" do
            {_, xv} = x
            { oper, v + Enum.product(xv) }
          else
            { oper, v }
          end
        end
       end)
    |> Kernel.elem(1)
    |> IO.inspect()
    #78683433
  end

end

Day3.task1_fixing_corrupted_data()
Day3.task2_fixing_corrupted_process()

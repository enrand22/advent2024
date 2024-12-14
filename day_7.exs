defmodule DayHelper do
  def parse_list_of_integers(list) do
    list
    |> Enum.map(&String.to_integer/1)
  end

  def generate(r) do
    Enum.reduce(1..r, [[]], fn _, acc ->
      for combination <- acc, option <- ["*", "+", "||"] do
        [option | combination]
      end
    end)
  end

  def iterate_operators({total, equation}) do
    r = length(equation) - 1

    result = calc_left_to_right(equation, generate(r))
    |> Enum.any?(fn x -> x == total end)

    {total, result}
  end

  def calc_left_to_right(equation, list_of_operations) do
    list_of_operations
    |> Enum.map(fn list_of_operators  ->
      equation
      |> Enum.with_index()
      |> Enum.reduce(0, fn {x, i}, acc ->
          if i == 0 do
            x
          else
            case Enum.at(list_of_operators, i - 1) do
            "+"  -> acc + x
            "*"  -> acc * x
            "||" -> String.to_integer("#{acc}#{x}")
            end
          end
      end)
    end)
  end
end

defmodule Day7 do
  def task1_operation_jungle do
    equations = File.read!("inputs/input_day7.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, [":", " "], trim: true))
    |> Enum.map(fn [head | tail ] -> {String.to_integer( head ), DayHelper.parse_list_of_integers( tail )} end)
    |> Enum.map(&DayHelper.iterate_operators(&1))

    Enum.sum(for {v, true} <- equations do
      v
    end)
    |> IO.inspect()
  end

end

Day7.task1_operation_jungle()

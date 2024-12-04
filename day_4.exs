defmodule DayHelper do
  def transpose(list) do
    list
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&(Tuple.to_list(&1) |> Enum.join()))
  end

  def diagonal_transpose(list, word) do
    word_length = String.length(word)

    list
    |> Enum.with_index()
    |> Enum.map(fn {_x, i} -> Enum.slice(list, i..(i + word_length - 1))  end)
    |> Enum.reject(fn x -> length(x) < word_length end)
    |> Enum.map(fn x ->
       x
       |> Enum.with_index()
       |> Enum.map(fn {w , i} -> String.duplicate(".", (word_length - 1) - i) <> w <> String.duplicate(".", i) end)
    end)
    |> Enum.map(&DayHelper.transpose/1)
  end

  def count_word(list) do
    list
    |> Enum.reduce(0, fn x, acc ->
      (Regex.scan(~r/(?=(XMAS|SAMX))/, x)
      |> List.flatten()
      |> Enum.count(fn x -> String.length(x) > 0 end)) + acc
    end)
  end

  def count_matches(list, regex) do
    list
    |> Enum.reduce(0, fn x, acc -> if Regex.match?(regex, x), do: acc + 1, else: acc end )
  end
end

defmodule Day4 do
  def task1_counting_xmases do
  xmatrix = File.read!("inputs/input_day4.txt")
  |> String.split("\n", trim: true)

  x = xmatrix
  |> DayHelper.count_word()

  y = xmatrix
  |> DayHelper.transpose()
  |> DayHelper.count_word()

  d = xmatrix
  |> DayHelper.diagonal_transpose("xmas")
  |> List.flatten()
  |> DayHelper.count_matches(~r/XMAS|SAMX/)

  dr = xmatrix
  |> Enum.reverse()
  |> DayHelper.diagonal_transpose("xmas")
  |> List.flatten()
  |> DayHelper.count_matches(~r/XMAS|SAMX/)

  IO.inspect(Enum.sum([x, y, d, dr]))
  #2390
  end

  def task2_counting_x_mases() do
    xmatrix = File.read!("inputs/input_day4.txt")
    |> String.split("\n", trim: true)

    d = xmatrix
    |> DayHelper.diagonal_transpose("mas")

    xmatrix_r = xmatrix
    |> Enum.map(&String.reverse/1)

    dr = xmatrix_r
    |> DayHelper.diagonal_transpose("mas")
    |> Enum.map(&Enum.reverse/1)

    d
    |> Enum.map(&Enum.with_index/1)
    |> Enum.with_index()
    |> Enum.map(fn {x, i} ->
      x
      |> Enum.reduce(0, fn {v, j}, acc ->
        if v == "MAS" || v == "SAM" do
          dr_list = Enum.at(dr, i)
          vr = Enum.at(dr_list, j)
          if vr == "MAS" || vr == "SAM", do: acc + 1, else: acc
        else
          acc
        end
      end)
    end)
    |> Enum.sum()
    |> IO.inspect()
    #1809
  end
end

Day4.task1_counting_xmases
Day4.task2_counting_x_mases

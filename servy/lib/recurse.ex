defmodule Recurse do
  def sum [h | t], total do
    IO.puts "Total #{total} Head: #{h} Tail: #{inspect t}"
    sum(t, total + h)
  end

  def sum([], total), do: total


  # def triple [h|t] do
  #   [h * 3 | triple(t)]
  # end
  #
  # def triple([]), do: []


  @doc "Tail call optimized triple"
  def triple(list) do
    triple(list, [])
  end

  defp triple([head|tail], current_list) do
    triple(tail, [head*3 | current_list])
  end

  defp triple([], current_list) do
    current_list |> Enum.reverse()
  end
end

IO.puts Recurse.sum([1, 2, 3, 4, 5], 0)
IO.inspect Recurse.triple([1, 2, 3, 4, 5])

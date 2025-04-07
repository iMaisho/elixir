defmodule Tutorials.Recursion.AddDigits do
  def addTo(0), do: 0

  def addTo(number) do
    number + addTo(number - 1)
  end

end

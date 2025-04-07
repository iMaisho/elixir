defmodule Tutorials.Recursion.PrintDigits do
  # Base Case
  def upTo(0) do
    :ok # return est implicite, car c'est la dernière ligne de notre fonction
  end

  def upTo(number) do
    IO.puts(number)
    upTo(number - 1)
  end

end

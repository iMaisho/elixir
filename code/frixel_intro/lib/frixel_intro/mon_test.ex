defmodule MonTest do

  @spec hello_world(String.t()) :: :ok
  def hello_world(name) do
    IO.puts("Bonjour #{name}")
  end
  def hello_world do
    IO.puts("Bonjour")
  end

  @spec ma_somme(list(integer()), integer()) :: integer()
  def ma_somme(nums, acc \\ 0)
  def ma_somme([], acc), do: acc
  def ma_somme([h | t], acc), do: ma_somme(t, h+acc)
end

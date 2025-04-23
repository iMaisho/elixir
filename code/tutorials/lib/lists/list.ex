defmodule Tutorials.Lists do
  @moduledoc """
  Sommaire des fonctions :

  1. sum
  """

  @doc """
  Retourne la somme d'une liste de nombres.
  """
  @spec sum(list(number()), number()) :: number()
  def sum(nums, acc \\ 0)
  def sum([], acc), do: acc
  def sum([h | t], acc), do: sum(t, h+acc)

end

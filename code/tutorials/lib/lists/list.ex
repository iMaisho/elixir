defmodule Tutorials.Lists do
  @moduledoc """
  Sommaire des fonctions :

  1. sum
  2. reverse_list
  """
  # ___________________ SOMME _________________________
  @doc """
  Retourne la somme d'une liste de nombres.
  """
  @spec sum(list(number()), number()) :: number()
  def sum(nums, acc \\ 0)
  def sum([], acc), do: acc
  def sum([h | t], acc), do: sum(t, h+acc)


  # ___________________ REVERSE _________________________
  @doc """
  Inverse l'ordre des éléments d'une liste
  """
  @spec reverse_list(list(any()), list(any())) :: list(any())
  def reverse_list(list, acc \\ [])
  def reverse_list([], acc), do: acc
  def reverse_list([h | t], acc), do: reverse_list(t, [h | acc])
end

defmodule Account do
  @moduledoc "Tagged-tuple case drill with guards for lesson 04."

  @doc """
  Map an account result to a status atom.

      iex> Account.status({:ok, 100})
      :open
      iex> Account.status({:ok, 0})
      :empty
      iex> Account.status({:error, :closed})
      :closed
  """
  def status(result) do
    case result do
      {:ok, balance} when balance > 0 -> :open
      {:ok, 0} -> :empty
      {:error, _} -> :closed
    end
  end
end

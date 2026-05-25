defmodule Steps do
  @moduledoc "with-chain drill for lesson 04."

  @doc """
  Run three steps in sequence with `with`. Each step takes the input
  and returns either {:ok, transformed} or {:error, reason}. If all
  three succeed, return {:ok, final_value}. The first failure
  short-circuits and is returned as-is.

      iex> Steps.run(1)
      {:ok, 16}
      iex> Steps.run(:fail_at_2)
      {:error, :step2_failed}
  """
  def run(_input), do: raise("TODO: use `with` chaining step1/1, step2/1, step3/1")

  @doc false
  def step1(:fail_at_1), do: {:error, :step1_failed}
  def step1(:fail_at_2), do: {:ok, :fail_at_2}
  def step1(:fail_at_3), do: {:ok, :fail_at_3}
  def step1(x), do: {:ok, x + 1}

  @doc false
  def step2(:fail_at_2), do: {:error, :step2_failed}
  def step2(:fail_at_3), do: {:ok, :fail_at_3}
  def step2(x), do: {:ok, x * 2}

  @doc false
  def step3(:fail_at_3), do: {:error, :step3_failed}
  def step3(x), do: {:ok, x * x}
end

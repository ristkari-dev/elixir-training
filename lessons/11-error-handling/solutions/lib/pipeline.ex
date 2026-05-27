defmodule Pipeline do
  @moduledoc "Chain three fallible steps with `with`."

  @doc """
  Run three steps. If all succeed, return `{:ok, final}`. The first
  failure short-circuits and is returned via the `else` clause.

      iex> Pipeline.run(1)
      {:ok, 16}
      iex> Pipeline.run(:fail_a)
      {:error, :step_a_failed}
  """
  def run(input) do
    with {:ok, a} <- step_a(input),
         {:ok, b} <- step_b(a),
         {:ok, c} <- step_c(b) do
      {:ok, c}
    else
      {:error, _} = err -> err
    end
  end

  @doc false
  def step_a(:fail_a), do: {:error, :step_a_failed}
  def step_a(x) when is_integer(x), do: {:ok, x + 1}
  def step_a(_), do: {:error, :step_a_failed}

  @doc false
  def step_b(:fail_b), do: {:error, :step_b_failed}
  def step_b(x) when is_integer(x), do: {:ok, x * 2}
  def step_b(_), do: {:error, :step_b_failed}

  @doc false
  def step_c(:fail_c), do: {:error, :step_c_failed}
  def step_c(x) when is_integer(x), do: {:ok, x * x}
  def step_c(_), do: {:error, :step_c_failed}
end

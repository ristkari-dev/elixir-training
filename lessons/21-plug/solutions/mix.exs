# Mix project skeleton for a lesson. `excoveralls` is included in every
# lesson's dependencies for consistency — the testing-deep-dive lesson
# (lesson 34) and onward use coverage reports; earlier lessons ignore it
# and the dep adds negligible compile time.

defmodule Lesson21Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :lesson_21_plug,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:plug, "~> 1.16"},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end
end

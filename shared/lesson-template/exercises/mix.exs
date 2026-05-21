defmodule {{MIX_APP_NAME_CAMEL}}.MixProject do
  use Mix.Project

  def project do
    [
      app: :{{MIX_APP_NAME}},
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
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end
end

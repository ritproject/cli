defmodule RitCLI.MixProject do
  use Mix.Project

  def project do
    [
      app: :rit_cli,
      version: "0.0.1",
      elixir: "~> 1.9",
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps(),
      escript: escript(),
      preferred_cli_env: preferred_cli_env()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      "test.all": ["test.static", "test.coverage"],
      "test.coverage": ["coveralls"],
      "test.static": ["credo list --strict --all"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11.2", only: [:dev, :test]},
      {:jason, "~> 1.1.2"},
      {:neuron, "~> 2.0.0"},
      {:recase, "~> 0.6.0"},
      {:yaml_elixir, "~> 2.4.0"}
    ]
  end

  defp escript do
    [
      main_module: RitCLI
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "test.all": :test,
      "test.coverage": :test,
      "test.static": :test
    ]
  end
end

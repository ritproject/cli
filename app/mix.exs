defmodule RitCLI.MixProject do
  use Mix.Project

  def project do
    [
      app: :rit_cli,
      version: "0.0.1",
      elixir: "~> 1.9",
      escript: escript(),
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "test.coverage": :test,
        "test.static": :test
      ]
    ]
  end

  def escript do
    [
      main_module: RitCLI
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1.2", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11.1", only: [:dev, :test]},
      {:jason, "~> 1.1.2"},
      {:neuron, "~> 2.0.0"},
      {:recase, "~> 0.6.0"}
    ]
  end

  defp aliases do
    [
      "test.coverage": ["coveralls"],
      "test.static": ["credo list --strict --all"]
    ]
  end
end

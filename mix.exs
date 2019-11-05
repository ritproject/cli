defmodule RitCLI.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://gitlab.com/ritproject/cli"

  def project do
    [
      app: :rit_cli,
      name: "Rit CLI",
      description: "Command line tools to aid developers on daily work.",
      source_url: @source_url,
      version: @version,
      elixir: "~> 1.9",
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      escript: escript(),
      package: package(),
      preferred_cli_env: preferred_cli_env(),
      releases: releases()
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
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false},
      {:jason, "~> 1.1.2"},
      {:neuron, "~> 2.0.0"},
      {:recase, "~> 0.6.0"},
      {:yaml_elixir, "~> 2.4.0"}
    ]
  end

  defp docs do
    [
      main: "readme",
      authors: ["Jonathan Moraes"],
      extras: ~w(CHANGELOG.md README.md docs/tunnel.md)
    ]
  end

  defp escript do
    [
      main_module: RitCLI,
      name: "rit",
      app: nil
    ]
  end

  defp package do
    [
      maintainers: ["Jonathan Moraes"],
      licenses: ["AGPL-3.0-or-later"],
      files: ~w(lib mix.exs CHANGELOG.md LICENSE README.md),
      links: %{"GitLab" => @source_url}
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

  defp releases do
    [
      rit: [
        include_executables_for: [:unix]
      ]
    ]
  end
end

defmodule RitCLI.Tunnel.Run.ParametersParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  alias RitCLI.Tunnel.Run.Parameters.{
    EnvironmentParser,
    InputParser,
    LinkDirParser,
    LinkModeParser
  }

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    if is_map(runner.settings) do
      runner
      |> LinkDirParser.parse()
      |> LinkModeParser.parse()
      |> EnvironmentParser.parse()
      |> InputParser.parse()
    else
      runner
    end
  end
end

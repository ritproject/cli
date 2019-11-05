defmodule RitCLI.Tunnel.Run.Parameters.EnvironmentParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "environment") do
      nil -> runner
      environment -> struct(runner, environment: Map.merge(runner.environment, environment))
    end
  end
end

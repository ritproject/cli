defmodule RitCLI.Tunnel.Run.Parameters.InputParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "input") do
      nil -> runner
      input -> struct(runner, input: Map.merge(runner.input, input))
    end
  end
end

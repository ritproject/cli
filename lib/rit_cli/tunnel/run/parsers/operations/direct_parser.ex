defmodule RitCLI.Tunnel.Run.Operations.DirectParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "direct") do
      nil -> runner
      operation -> struct(runner, operation: operation, operation_mode: :execute)
    end
  end
end

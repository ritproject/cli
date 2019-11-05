defmodule RitCLI.Tunnel.Run.Operations.RedirectParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "redirect") do
      nil -> runner
      operation -> struct(runner, operation: operation, operation_mode: :redirect)
    end
  end
end

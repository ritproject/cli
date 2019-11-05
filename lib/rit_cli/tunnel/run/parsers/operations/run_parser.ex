defmodule RitCLI.Tunnel.Run.Operations.RunParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "run") do
      nil -> runner
      operation -> parse_run(runner, operation)
    end
  end

  defp parse_run(runner, operation) do
    if Enum.empty?(runner.args) do
      struct(runner, operation: operation, operation_mode: :execute)
    else
      parse_strict(runner, operation)
    end
  end

  defp parse_strict(runner, operation) do
    if runner.strict? do
      runner
    else
      struct(runner, operation: operation, operation_mode: :execute_and_continue)
    end
  end
end

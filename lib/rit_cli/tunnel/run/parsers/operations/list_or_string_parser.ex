defmodule RitCLI.Tunnel.Run.Operations.ListOrStringParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{settings: settings} = runner) do
    if is_binary(settings) or is_list(settings) do
      struct(runner, operation: settings, operation_mode: :execute)
    else
      runner
    end
  end
end

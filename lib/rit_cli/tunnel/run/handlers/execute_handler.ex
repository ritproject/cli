defmodule RitCLI.Tunnel.Run.ExecuteHandler do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.Run.Runner

  alias RitCLI.Tunnel.Run.Handler.Execute.{Executor, Redirector}

  @spec handle(Meta.t(), Runner.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle(%Meta{} = meta, %Runner{} = runner) do
    case runner.operation_mode do
      :execute -> Executor.execute(meta, runner)
      :execute_and_continue -> Executor.execute_and_continue(meta, runner)
      :redirect -> Redirector.redirect(meta, runner)
      _nil -> {:error, unknown_operation_error(meta)}
    end
  end

  defp unknown_operation_error(meta) do
    Meta.error(meta, :unknown_operation, "operation to perform not found on settings file")
  end
end

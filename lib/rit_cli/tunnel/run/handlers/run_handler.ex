defmodule RitCLI.Tunnel.Run.RunHandler do
  @moduledoc false

  alias RitCLI.Meta

  alias RitCLI.Tunnel.Run.{
    ExecuteHandler,
    OperationsParser,
    ParametersParser,
    Runner
  }

  @spec handle(Meta.t(), Runner.t(), map | list(String.t()) | String.t(), list(String.t())) ::
          {:ok, Meta.t()} | {:error, Meta.t()}
  def handle(%Meta{} = meta, %Runner{} = runner, settings, args) do
    ExecuteHandler.handle(meta, update_runner(runner, settings, args))
  end

  @spec update_runner(Runner.t(), map | list(String.t()) | String.t(), list(String.t())) ::
          Runner.t()
  def update_runner(%Runner{} = runner, settings, args) do
    struct(runner, args: args, settings: settings)
    |> ParametersParser.parse()
    |> OperationsParser.parse()
  end
end

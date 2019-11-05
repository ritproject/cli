defmodule RitCLI.Config.Tunnel.ArgumentsHandler do
  @moduledoc false

  alias RitCLI.Config.Tunnel.CommandHandler
  alias RitCLI.Meta

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> CommandHandler.handle_command(meta, arg)
      _error -> {:error, empty_command_error(meta)}
    end
  end

  defp empty_command_error(meta) do
    meta
    |> Meta.error(:empty_command, "at least a config tunnel command must be provided")
    |> Meta.help()
  end
end

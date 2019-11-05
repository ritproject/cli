defmodule RitCLI.Tunnel.ArgumentsHandler do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Meta.ArgumentsParser
  alias RitCLI.Tunnel.{CommandHandler, ModifierHandler}

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_argument(meta, arg)
      _error -> {:error, empty_command_error(meta)}
    end
  end

  defp handle_argument(meta, arg) do
    case ArgumentsParser.parse_modifier(arg) do
      {:ok, value} -> ModifierHandler.handle_modifier(meta, value)
      _error -> CommandHandler.handle_command(meta, arg)
    end
  end

  defp empty_command_error(meta) do
    meta
    |> Meta.error(:empty_command, "at least a command must be provided")
    |> Meta.help()
  end
end

defmodule RitCLI.Tunnel.CommandHandler do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.CommandParser
  alias RitCLI.Tunnel.{List, Run}

  @spec handle_command(Meta.t(), String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_command(%Meta{} = meta, value) do
    case CommandParser.parse(value) do
      {:ok, command} -> redirect_to_command(meta, command)
      {:error, error} -> {:error, invalid_command_error(meta, error)}
    end
  end

  defp redirect_to_command(meta, command) do
    case command do
      :help -> {:ok, Meta.help(meta)}
      :list -> List.handle_arguments(meta)
      :run -> Run.handle_arguments(meta)
    end
  end

  defp invalid_command_error(meta, error), do: Meta.error(meta, error)
end

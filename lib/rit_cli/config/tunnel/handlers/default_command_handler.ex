defmodule RitCLI.Config.Tunnel.DefaultCommandHandler do
  @moduledoc false

  alias RitCLI.Config.Tunnel.DefaultCommandParser
  alias RitCLI.Config.Tunnel.Default.{Set, Unset}
  alias RitCLI.Meta

  @spec handle_command(Meta.t(), String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_command(%Meta{} = meta, value) do
    case DefaultCommandParser.parse(value) do
      {:ok, command} -> redirect_to_command(meta, command)
      {:error, error} -> {:error, invalid_command_error(meta, error)}
    end
  end

  defp redirect_to_command(meta, command) do
    case command do
      :help -> {:ok, Meta.help(meta)}
      :set -> Set.handle_arguments(meta)
      :unset -> Unset.handle_arguments(meta)
    end
  end

  defp invalid_command_error(meta, error), do: Meta.error(meta, error)
end

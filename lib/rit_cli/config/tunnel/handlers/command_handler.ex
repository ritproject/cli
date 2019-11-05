defmodule RitCLI.Config.Tunnel.CommandHandler do
  @moduledoc false

  alias RitCLI.Config.Tunnel.{
    Add,
    CommandParser,
    Default,
    Edit,
    List,
    Remove,
    Show
  }

  alias RitCLI.Meta

  @spec handle_command(Meta.t(), String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_command(%Meta{} = meta, value) do
    case CommandParser.parse(value) do
      {:ok, command} -> redirect_to_command(meta, command)
      {:error, error} -> {:error, invalid_command_error(meta, error)}
    end
  end

  defp redirect_to_command(meta, command) do
    case command do
      :add -> Add.handle_arguments(meta)
      :default -> Default.handle_arguments(meta)
      :edit -> Edit.handle_arguments(meta)
      :help -> {:ok, Meta.help(meta)}
      :list -> List.handle_arguments(meta)
      :remove -> Remove.handle_arguments(meta)
      :show -> Show.handle_arguments(meta)
    end
  end

  defp invalid_command_error(meta, error), do: Meta.error(meta, error)
end

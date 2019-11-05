defmodule RitCLI.Config.Tunnel.CommandParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type command :: :add | :default | :edit | :help | :list | :remove | :show

  @valid_commands %{
    "a" => :add,
    "add" => :add,
    "d" => :default,
    "default" => :default,
    "e" => :edit,
    "edit" => :edit,
    "h" => :help,
    "help" => :help,
    "l" => :list,
    "list" => :list,
    "r" => :remove,
    "remove" => :remove,
    "s" => :show,
    "show" => :show
  }

  @spec parse(String.t()) :: {:ok, command} | {:error, Error.t()}
  def parse(value) do
    command = Map.get(@valid_commands, Recase.to_snake(value))

    if command != nil do
      {:ok, command}
    else
      {:error, invalid_command_error(value)}
    end
  end

  defp invalid_command_error(invalid_command) do
    Error.build(
      __MODULE__,
      :invalid_command,
      "the config tunnel command '%{command}' is invalid",
      command: invalid_command
    )
  end
end

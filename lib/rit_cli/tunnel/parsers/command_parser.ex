defmodule RitCLI.Tunnel.CommandParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type command :: :help | :list | :run

  @valid_commands %{
    "h" => :help,
    "help" => :help,
    "l" => :list,
    "list" => :list,
    "r" => :run,
    "run" => :run
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
      "the command '%{command}' is invalid",
      command: invalid_command
    )
  end
end

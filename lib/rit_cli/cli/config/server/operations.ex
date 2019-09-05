defmodule RitCLI.CLI.Config.Server.Operations do
  @moduledoc false

  alias RitCLI.CLI.Config.Server
  alias RitCLI.CLI.Config.Server.Input
  alias RitCLI.CLI.Config.Server.Operations

  @spec add_server(Server.Input.Add.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom, Output.t()}
  def add_server(%Input.Add{} = input, config) do
    Operations.Add.add_server(input, config)
  end

  @spec edit_server(Server.Input.Edit.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom, Output.t()}
  def edit_server(%Input.Edit{} = input, config) do
    Operations.Edit.edit_server(input, config)
  end

  @spec remove_server(Server.Input.Remove.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom, Output.t()}
  def remove_server(%Input.Remove{} = input, config) do
    Operations.Remove.remove_server(input, config)
  end
end

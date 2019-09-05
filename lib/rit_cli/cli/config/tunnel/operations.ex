defmodule RitCLI.CLI.Config.Tunnel.Operations do
  @moduledoc false

  alias RitCLI.CLI.Config.Tunnel
  alias RitCLI.CLI.Config.Tunnel.Input
  alias RitCLI.CLI.Config.Tunnel.Operations

  @spec add_tunnel(Tunnel.Input.Add.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def add_tunnel(%Input.Add{} = input, config) do
    Operations.Add.add_tunnel(input, config)
  end

  @spec edit_tunnel(Tunnel.Input.Edit.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def edit_tunnel(%Input.Edit{} = input, config) do
    Operations.Edit.edit_tunnel(input, config)
  end

  @spec remove_tunnel(Tunnel.Input.Remove.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def remove_tunnel(%Input.Remove{} = input, config) do
    Operations.Remove.remove_tunnel(input, config)
  end
end

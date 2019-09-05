defmodule RitCLI.CLI.Config.Tunnel.Default.Operations do
  @moduledoc false

  alias RitCLI.CLI.Config.Tunnel
  alias RitCLI.CLI.Config.Tunnel.Default.Input
  alias RitCLI.CLI.Config.Tunnel.Default.Operations

  @spec set_default_tunnel(Input.Set.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def set_default_tunnel(%Input.Set{} = input, config) do
    Operations.Set.set_default_tunnel(input, config)
  end

  @spec unset_default_tunnel(Input.Unset.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def unset_default_tunnel(%Input.Unset{} = input, config) do
    Operations.Unset.unset_default_tunnel(input, config)
  end
end

defmodule RitCLI.CLI.Config.Tunnel.Operations.Add do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Tunnel.Input

  @spec add_tunnel(Input.Add.t(), Config.Tunnel.t()) ::
          {:ok, Config.Tunnel.t()} | {:error, atom, Output.t()}
  def add_tunnel(
        %Input.Add{from: from, name: name, reference: reference},
        %Config.Tunnel{tunnels: tunnels} = config
      ) do
    if Config.Tunnel.has_tunnel?(name, config) do
      {
        :error,
        :config_tunnel_add_non_unique,
        %Output{
          error: "Tunnel '#{name}' already exists",
          module_id: :config_tunnel_add
        }
      }
    else
      name = String.to_atom(name)
      tunnels = Map.put(tunnels, name, %{from: from, reference: reference})

      {:ok, struct(config, tunnels: tunnels)}
    end
  end
end

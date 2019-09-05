defmodule RitCLI.CLI.Config.Tunnel.Operations.Remove do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Tunnel.Input

  @spec remove_tunnel(Input.Remove.t(), Config.Tunnel.t()) ::
          {:ok, Config.Tunnel.t()} | {:error, atom, Output.t()}
  def remove_tunnel(
        %Input.Remove{name: name},
        %Config.Tunnel{tunnels: tunnels, defaults: defaults} = config
      ) do
    if Config.Tunnel.has_tunnel?(name, config) do
      tunnels = Map.drop(tunnels, [String.to_atom(name)])

      defaults =
        Enum.reduce(defaults, %{}, fn {path, path_tunnel_name}, map ->
          if path_tunnel_name == name do
            map
          else
            Map.put(map, path, path_tunnel_name)
          end
        end)

      {:ok, struct(config, tunnels: tunnels, defaults: defaults)}
    else
      {
        :error,
        :config_tunnel_remove_not_found,
        %Output{
          error: "Tunnel '#{name}' not found",
          module_id: :config_tunnel_remove
        }
      }
    end
  end
end

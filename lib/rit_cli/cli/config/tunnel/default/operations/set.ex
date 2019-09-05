defmodule RitCLI.CLI.Config.Tunnel.Default.Operations.Set do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Tunnel.Default.Input

  @spec set_default_tunnel(Input.Set.t(), Config.Tunnel.t()) ::
          {:ok, Config.Tunnel.t()} | {:error, atom, Output.t()}
  def set_default_tunnel(
        %Input.Set{name: name, path: path},
        %Config.Tunnel{defaults: defaults} = config
      ) do
    if Config.Tunnel.has_tunnel?(name, config) do
      defaults =
        if path != "" do
          Map.put(defaults, String.to_atom(path), name)
        else
          Map.put(defaults, :*, name)
        end

      {:ok, struct(config, defaults: defaults)}
    else
      {
        :error,
        :config_tunnel_set_default_not_found,
        %Output{
          error: "Tunnel '#{name}' not found",
          module_id: :config_tunnel_set_default
        }
      }
    end
  end
end

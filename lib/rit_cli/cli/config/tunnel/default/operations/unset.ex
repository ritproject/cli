defmodule RitCLI.CLI.Config.Tunnel.Default.Operations.Unset do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Tunnel.Default.Input

  @spec unset_default_tunnel(Input.Unset.t(), Config.Tunnel.t()) ::
          {:ok, Config.Tunnel.t()} | {:error, atom, Output.t()}
  def unset_default_tunnel(
        %Input.Unset{path: path},
        %Config.Tunnel{defaults: defaults} = config
      ) do
    path = String.to_atom(path)

    if Map.has_key?(defaults, path) do
      {:ok, struct(config, defaults: Map.drop(defaults, [path]))}
    else
      message =
        if path != :* do
          "There are no default tunnels set on path"
        else
          "There are no global default tunnel set"
        end

      {
        :error,
        :config_tunnel_unset_default_input_error,
        %Output{
          error: message,
          module_id: :config_tunnel_unset_default
        }
      }
    end
  end
end

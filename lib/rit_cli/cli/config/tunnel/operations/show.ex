defmodule RitCLI.CLI.Config.Tunnel.Operations.Show do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Tunnel.Input

  @spec show_tunnel(Input.Show.t(), Config.Tunnel.t()) ::
          {:ok, binary()} | {:error, atom, Output.t()}
  def show_tunnel(
        %Input.Show{name: name},
        %Config.Tunnel{tunnels: tunnels, defaults: defaults} = config
      ) do
    if Config.Tunnel.has_tunnel?(name, config) do
      %{from: from, reference: reference} = Map.get(tunnels, String.to_atom(name))

      tunnel = "- #{name}: #{reference} (#{from})\n"

      message =
        if Enum.empty?(defaults) do
          tunnel
        else
          tunnel <>
            Enum.reduce(defaults, "", fn {path, tunnel_name}, message ->
              if tunnel_name == name do
                message <> if path == :*, do: "(global)\n", else: "#{to_string(path)}\n"
              else
                message
              end
            end)
        end

      {:ok, message}
    else
      {
        :error,
        :config_tunnel_show_not_found,
        %Output{
          error: "Tunnel '#{name}' not found",
          module_id: :config_tunnel_show
        }
      }
    end
  end
end

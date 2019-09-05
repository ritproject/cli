defmodule RitCLI.CLI.Config.Tunnel.Operations.Edit do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Tunnel.Input

  @spec edit_tunnel(Input.Edit.t(), Config.Tunnel.t()) ::
          {:ok, Config.Tunnel.t()} | {:error, atom, Output.t()}
  def edit_tunnel(%Input.Edit{current_name: current_name} = input, %Config.Tunnel{} = config) do
    if Config.Tunnel.has_tunnel?(current_name, config) do
      {:ok, do_edit_tunnel(input, config)}
    else
      {
        :error,
        :config_tunnel_edit_not_found,
        %Output{
          error: "Tunnel '#{current_name}' not found",
          module_id: :config_tunnel_edit
        }
      }
    end
  end

  defp do_edit_tunnel(
         %Input.Edit{current_name: current_name, name: name} = input,
         %Config.Tunnel{tunnels: tunnels} = config
       ) do
    {tunnel, tunnels} = Map.pop(tunnels, String.to_atom(current_name))
    {key, update_defaults?} = relate_names(current_name, name)

    if update_defaults? do
      fetch_defaults(config, current_name, name)
    else
      config
    end
    |> struct(tunnels: Map.put(tunnels, String.to_atom(key), update_tunnel(tunnel, input)))
  end

  defp relate_names(current_name, name) do
    if name != "" and name != current_name do
      {name, true}
    else
      {current_name, false}
    end
  end

  defp fetch_defaults(%Config.Tunnel{defaults: defaults} = config, current_name, name) do
    defaults =
      Enum.reduce(defaults, %{}, fn {path, path_tunnel_name}, map ->
        if path_tunnel_name == current_name do
          Map.put(map, path, name)
        else
          Map.put(map, path, path_tunnel_name)
        end
      end)

    struct(config, defaults: defaults)
  end

  defp update_tunnel(tunnel, %Input.Edit{from: from, reference: reference}) do
    tunnel
    |> maybe_update_from(from)
    |> maybe_update_reference(reference)
  end

  defp maybe_update_from(tunnel, ""), do: tunnel
  defp maybe_update_from(tunnel, from), do: Map.put(tunnel, :from, from)

  defp maybe_update_reference(tunnel, reference) do
    case reference do
      "" -> tunnel
      reference -> Map.put(tunnel, :reference, reference)
    end
  end
end

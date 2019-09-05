defmodule RitCLI.CLI.Config.Server.Operations.Edit do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Server.Input

  @spec edit_server(Input.Edit.t(), Config.Server.t()) ::
          {:ok, Config.Server.t()} | {:error, atom, Output.t()}
  def edit_server(%Input.Edit{current_name: current_name} = input, %Config.Server{} = config) do
    if Config.Server.has_server?(current_name, config) do
      {:ok, do_edit_server(input, config)}
    else
      {
        :error,
        :config_server_edit_not_found,
        %Output{
          error: "Server '#{current_name}' not found",
          module_id: :config_server_edit
        }
      }
    end
  end

  defp do_edit_server(
         %Input.Edit{current_name: current_name, name: name} = input,
         %Config.Server{servers: servers} = config
       ) do
    {server, servers} = Map.pop(servers, String.to_atom(current_name))
    {key, update_defaults?} = relate_names(current_name, name)

    if update_defaults? do
      fetch_defaults(config, current_name, name)
    else
      config
    end
    |> struct(servers: Map.put(servers, String.to_atom(key), update_server(server, input)))
  end

  defp relate_names(current_name, name) do
    if name != "" and name != current_name do
      {name, true}
    else
      {current_name, false}
    end
  end

  defp fetch_defaults(%Config.Server{defaults: defaults} = config, current_name, name) do
    defaults =
      Enum.reduce(defaults, %{}, fn {path, path_server_name}, map ->
        if path_server_name == current_name do
          Map.put(map, path, name)
        else
          Map.put(map, path, path_server_name)
        end
      end)

    struct(config, defaults: defaults)
  end

  defp update_server(server, %Input.Edit{hostname: hostname, port: port}) do
    server
    |> maybe_update_hostname(hostname)
    |> maybe_update_port(port)
  end

  defp maybe_update_hostname(server, ""), do: server
  defp maybe_update_hostname(server, hostname), do: Map.put(server, :hostname, hostname)

  defp maybe_update_port(server, ""), do: server
  defp maybe_update_port(server, port), do: Map.put(server, :port, String.to_integer(port))
end

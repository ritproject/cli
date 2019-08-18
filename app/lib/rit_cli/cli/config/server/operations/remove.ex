defmodule RitCLI.CLI.Config.Server.Operations.Remove do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Server.Input

  @spec remove_server(Input.Remove.t(), Config.Server.t()) ::
          {:ok, Config.Server.t()} | {:error, atom(), Output.t()}
  def remove_server(
        %Input.Remove{name: name},
        %Config.Server{servers: servers, defaults: defaults} = config
      ) do
    if Config.Server.has_server?(name, config) do
      servers = Map.drop(servers, [String.to_atom(name)])

      defaults =
        Enum.reduce(defaults, %{}, fn {path, path_server_name}, map ->
          if path_server_name == name do
            map
          else
            Map.put(map, path, path_server_name)
          end
        end)

      {:ok, struct!(config, servers: servers, defaults: defaults)}
    else
      {
        :error,
        :config_server_remove_not_found,
        %Output{
          error: "Server '#{name}' not found",
          module_id: :config_server_remove
        }
      }
    end
  end
end

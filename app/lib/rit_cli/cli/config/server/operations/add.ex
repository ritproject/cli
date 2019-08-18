defmodule RitCLI.CLI.Config.Server.Operations.Add do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Server.Input

  @spec add_server(Input.Add.t(), Config.Server.t()) ::
          {:ok, Config.Server.t()} | {:error, atom(), Output.t()}
  def add_server(
        %Input.Add{name: name, hostname: hostname, port: port},
        %Config.Server{servers: servers} = config
      ) do
    if Config.Server.has_server?(name, config) do
      {
        :error,
        :config_server_add_non_unique,
        %Output{
          error: "Server '#{name}' already exists",
          module_id: :config_server_add
        }
      }
    else
      name = String.to_atom(name)
      port = String.to_integer(port)
      servers = Map.put(servers, name, %{hostname: hostname, port: port})

      {:ok, struct!(config, servers: servers)}
    end
  end
end

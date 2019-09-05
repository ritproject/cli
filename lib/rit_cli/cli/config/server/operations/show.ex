defmodule RitCLI.CLI.Config.Server.Operations.Show do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Server.Input

  @spec show_server(Input.Show.t(), Config.Server.t()) ::
          {:ok, binary()} | {:error, atom, Output.t()}
  def show_server(
        %Input.Show{name: name},
        %Config.Server{servers: servers, defaults: defaults} = config
      ) do
    if Config.Server.has_server?(name, config) do
      %{hostname: hostname, port: port} = Map.get(servers, String.to_atom(name))

      server =
        if port != 80 do
          "- #{name}: #{hostname}:#{port}\n"
        else
          "- #{name}: #{hostname}\n"
        end

      message =
        if Enum.empty?(defaults) do
          server
        else
          server <>
            Enum.reduce(defaults, "", fn {path, server_name}, message ->
              if server_name == name do
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
        :config_server_show_not_found,
        %Output{
          error: "Server '#{name}' not found",
          module_id: :config_server_show
        }
      }
    end
  end
end

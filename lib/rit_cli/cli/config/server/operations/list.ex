defmodule RitCLI.CLI.Config.Server.Operations.List do
  @moduledoc false

  alias RitCLI.CLI.Config

  @spec list_servers(Config.Server.t()) :: String.t()
  def list_servers(%Config.Server{servers: servers, defaults: defaults}) do
    if Enum.empty?(servers) do
      "There are no servers configured on your machine"
    else
      servers = """
      # Servers

      #{Enum.reduce(servers, "", &parse_server/2)}
      """

      if Enum.empty?(defaults) do
        servers <> "There are no default servers configured on your machine\n"
      else
        servers <>
          """
          ## Default Paths

          #{Enum.reduce(defaults, "", &parse_default/2)}
          """
      end
    end
  end

  defp parse_server({name, %{hostname: hostname, port: port}}, message) do
    if port != 80 do
      message <> "- #{to_string(name)}: #{hostname}:#{port}\n"
    else
      message <> "- #{to_string(name)}: #{hostname}\n"
    end
  end

  defp parse_default({path, server_name}, message) do
    path = if path == :*, do: "(global)", else: to_string(path)
    message <> "- #{path}: #{server_name}\n"
  end
end

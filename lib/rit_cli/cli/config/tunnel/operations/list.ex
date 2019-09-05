defmodule RitCLI.CLI.Config.Tunnel.Operations.List do
  @moduledoc false

  alias RitCLI.CLI.Config

  @spec list_tunnels(Config.Tunnel.t()) :: String.t()
  def list_tunnels(%Config.Tunnel{tunnels: tunnels, defaults: defaults}) do
    if Enum.empty?(tunnels) do
      "There are no tunnels configured on your machine"
    else
      tunnels = """
      # Tunnels

      #{Enum.reduce(tunnels, "", &parse_tunnel/2)}
      """

      if Enum.empty?(defaults) do
        tunnels <> "There are no default tunnels configured on your machine\n"
      else
        tunnels <>
          """
          ## Default Paths

          #{Enum.reduce(defaults, "", &parse_default/2)}
          """
      end
    end
  end

  defp parse_tunnel({name, %{from: from, reference: reference}}, message) do
    message <> "- #{to_string(name)}: #{reference} (#{from})\n"
  end

  defp parse_default({path, tunnel_name}, message) do
    path = if path == :*, do: "(global)", else: to_string(path)
    message <> "- #{path}: #{tunnel_name}\n"
  end
end

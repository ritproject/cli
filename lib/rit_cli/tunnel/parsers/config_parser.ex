defmodule RitCLI.Tunnel.ConfigParser do
  @moduledoc false

  alias RitCLI.Config.Tunnel.ArgumentsParser
  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta.Error

  @spec parse(String.t()) :: {:ok, map} | {:error, Error.t()}
  def parse(value) do
    case ArgumentsParser.parse_name(value, :config) do
      {:ok, name} -> TunnelStorage.get_config(TunnelStorage.get_storage(), name)
      error -> error
    end
  end
end

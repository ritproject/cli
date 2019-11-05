defmodule RitCLI.Tunnel.PathParser do
  @moduledoc false

  alias RitCLI.Config.Tunnel.ArgumentsParser
  alias RitCLI.Meta.Error

  @spec parse(String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def parse(value), do: ArgumentsParser.parse_path(value)
end

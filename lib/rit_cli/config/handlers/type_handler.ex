defmodule RitCLI.Config.TypeHandler do
  @moduledoc false

  alias RitCLI.Config.{Tunnel, TypeParser}
  alias RitCLI.Meta

  @spec handle_type(Meta.t(), String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_type(%Meta{} = meta, value) do
    case TypeParser.parse(value) do
      {:ok, type} -> redirect_to_type(meta, type)
      {:error, error} -> {:error, invalid_type_error(meta, error)}
    end
  end

  defp redirect_to_type(meta, type) do
    case type do
      :help -> {:ok, Meta.help(meta)}
      :tunnel -> Tunnel.handle_arguments(meta)
    end
  end

  defp invalid_type_error(meta, error), do: Meta.error(meta, error)
end

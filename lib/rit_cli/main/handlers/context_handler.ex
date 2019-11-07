defmodule RitCLI.Main.ContextHandler do
  @moduledoc false

  alias RitCLI.{Config, Meta, Tunnel}
  alias RitCLI.Main.ContextParser

  @spec handle_context(Meta.t(), String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_context(%Meta{} = meta, value) do
    case ContextParser.parse(value) do
      {:ok, context} -> redirect_to_context(meta, context)
      {:error, error} -> {:error, invalid_context_error(meta, error)}
    end
  end

  defp redirect_to_context(meta, context) do
    case context do
      :config -> Config.handle_arguments(meta)
      :help -> {:ok, Meta.help(meta)}
      :tunnel -> Tunnel.handle_arguments(meta)
      :version -> {:ok, Meta.version(meta)}
    end
  end

  defp invalid_context_error(meta, error), do: Meta.error(meta, error)
end

defmodule RitCLI.Main.ArgumentsHandler do
  @moduledoc false

  alias RitCLI.Meta

  alias RitCLI.Main.{ContextHandler, ModifierHandler}
  alias RitCLI.Meta.ArgumentsParser

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_argument(meta, arg)
      {:error, :empty} -> {:error, empty_argument_error(meta)}
      {:error, :nothing_to_parse} -> {:error, empty_context_error(meta)}
    end
  end

  defp handle_argument(meta, arg) do
    case ArgumentsParser.parse_modifier(arg) do
      {:ok, value} -> ModifierHandler.handle_modifier(meta, value)
      _error -> ContextHandler.handle_context(meta, arg)
    end
  end

  defp empty_argument_error(meta) do
    meta
    |> Meta.error(:empty_argument, "at least a context must be provided")
    |> Meta.help()
  end

  defp empty_context_error(meta) do
    meta
    |> Meta.error(:empty_context, "at least a context must be provided")
    |> Meta.help()
  end
end

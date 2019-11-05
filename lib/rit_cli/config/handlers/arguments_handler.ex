defmodule RitCLI.Config.ArgumentsHandler do
  @moduledoc false

  alias RitCLI.Config.TypeHandler
  alias RitCLI.Meta

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> TypeHandler.handle_type(meta, arg)
      _error -> {:error, empty_type_error(meta)}
    end
  end

  defp empty_type_error(meta) do
    meta
    |> Meta.error(:empty_type, "at least a config type must be provided")
    |> Meta.help()
  end
end

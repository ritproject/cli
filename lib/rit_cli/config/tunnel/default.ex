defmodule RitCLI.Config.Tunnel.Default do
  @moduledoc false

  alias RitCLI.Config.Tunnel.DefaultArgumentsHandler
  alias RitCLI.Meta

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel default type selected")
    |> DefaultArgumentsHandler.handle_arguments()
  end
end

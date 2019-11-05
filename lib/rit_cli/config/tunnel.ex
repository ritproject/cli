defmodule RitCLI.Config.Tunnel do
  @moduledoc false

  alias RitCLI.Config.Tunnel.ArgumentsHandler
  alias RitCLI.Meta

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel type selected")
    |> ArgumentsHandler.handle_arguments()
  end
end

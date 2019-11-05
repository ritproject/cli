defmodule RitCLI.Tunnel.Run do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.Run.Runner
  alias RitCLI.Tunnel.{SettingsManager, SourceManager}

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "tunnel run command selected")
    |> do_handle_arguments()
    |> maybe_log_success()
  end

  defp do_handle_arguments(meta) do
    with {:ok, source_path} <- SourceManager.fetch(meta),
         {:ok, settings} <- SettingsManager.extract(meta, source_path) do
      Runner.run(meta, settings, source_path)
    end
  end

  defp maybe_log_success({:ok, meta}) do
    {:ok, Meta.success(meta, "tunnel successfully performed the operation")}
  end

  defp maybe_log_success({:error, meta}) do
    {:error, meta}
  end
end

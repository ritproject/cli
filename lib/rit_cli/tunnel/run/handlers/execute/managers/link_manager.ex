defmodule RitCLI.Tunnel.Run.Handler.Execute.LinkManager do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.Run.Runner

  @spec link(Meta.t(), Runner.t()) :: {:ok, Meta.t(), Runner.t()} | {:error, Meta.t()}
  def link(%Meta{} = meta, %Runner{} = runner) do
    if runner.link_mode != :none do
      do_link(meta, runner)
    else
      {:ok, meta, runner}
    end
  end

  defp do_link(meta, runner) do
    if runner.link_dir != "" do
      link_path = Path.expand(runner.link_dir, runner.source_path)
      File.rm_rf(link_path)
      perform_link(meta, runner, link_path)
    else
      {:error, link_dir_undefined_error(meta)}
    end
  end

  defp perform_link(meta, %{link_mode: link_mode, target_path: target_path} = runner, link_path) do
    case link_mode do
      :symlink -> File.ln_s!(target_path, link_path)
      :copy -> File.cp_r!(target_path, link_path)
    end

    {:ok, meta, runner}
  rescue
    error -> {:error, link_failure_error(meta, error, link_mode, link_path, target_path)}
  end

  defp link_dir_undefined_error(meta) do
    Meta.error(meta, :undefined_link_dir, "link_dir must be set if link_mode is not 'none'")
  end

  defp link_failure_error(meta, error, link_mode, link_path, target_path) do
    Meta.error(
      meta,
      :link_failed,
      "OS failed to link target path with source",
      error: inspect(error),
      mode: link_mode,
      source_path: link_path,
      target_path: target_path
    )
  end
end

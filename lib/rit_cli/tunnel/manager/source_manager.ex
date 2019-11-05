defmodule RitCLI.Tunnel.SourceManager do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.{Git, Meta}
  alias RitCLI.Meta.Error

  @rit_dir ".rit"
  @source_dir "#{@rit_dir}/tunnel_sources"

  @spec fetch(Meta.t()) :: {:ok, String.t()} | {:error, Meta.t()}
  def fetch(%Meta{tunnel: %{path: nil}} = meta) do
    fetch(Meta.tunnel(meta, path: Path.expand(".")))
  end

  def fetch(%Meta{tunnel: %{config: nil, path: path}} = meta) do
    case get_default_config(path) do
      {:ok, config} -> fetch(Meta.tunnel(meta, config: config))
      {:error, error} -> {:error, unknown_default_config_error(meta, error)}
    end
  end

  def fetch(%Meta{tunnel: %{config: config}} = meta) do
    case fetch_config(config) do
      {:ok, source_path} -> {:ok, source_path}
      {:error, error} -> {:error, source_fetch_failure_error(meta, error)}
    end
  end

  defp get_default_config(path) do
    storage = TunnelStorage.get_storage()

    case TunnelStorage.get_default_config(storage, path) do
      {:ok, config} -> {:ok, config}
      {:error, _error} -> TunnelStorage.get_global_default_config(storage)
    end
  end

  defp fetch_config(%{from: "local", reference: reference}) do
    if File.exists?(reference) do
      path = get_source_path("local", reference)

      File.rm_rf!(path)
      File.mkdir_p!(path)

      File.cp_r!(reference, path)

      {:ok, path}
    else
      {:error, unknown_local_config_reference_error(reference)}
    end
  rescue
    error -> {:error, failed_to_create_local_source_directory(error)}
  end

  defp fetch_config(%{from: "repo", reference: reference}) do
    path = get_source_path("repo", reference)

    case fetch_from_repo(reference, path) do
      {:ok, _result, 0} -> {:ok, path}
      {:ok, result, code} -> {:error, failed_to_fetch_from_repo(reference, result, code)}
    end
  end

  defp fetch_from_repo(reference, path) do
    if File.exists?(path) do
      File.cd!(path, fn -> Git.run(~w(pull origin master)) end)
    else
      File.mkdir_p!(path)
      File.cd!(path, fn -> Git.run(~w(clone #{reference} .)) end)
    end
  end

  defp get_source_path(from, reference) do
    path = Base.url_encode64(from <> reference)
    home = System.get_env("HOME", "")
    "#{home}/#{@source_dir}/#{path}"
  end

  defp unknown_local_config_reference_error(reference) do
    Error.build(
      __MODULE__,
      :config_reference_not_found,
      "the configuration reference on '#{reference}' does not exists",
      reference: reference
    )
  end

  defp failed_to_create_local_source_directory(error) do
    Error.build(
      __MODULE__,
      :failed_to_source,
      "OS filesystem command reported a failure",
      error: inspect(error)
    )
  end

  defp failed_to_fetch_from_repo(reference, result, code) do
    Error.build(
      __MODULE__,
      :failed_to_fetch,
      "git command reported a failure",
      reference: reference,
      result: result,
      code: code
    )
  end

  defp unknown_default_config_error(meta, error), do: Meta.error(meta, error)
  defp source_fetch_failure_error(meta, error), do: Meta.error(meta, error)
end

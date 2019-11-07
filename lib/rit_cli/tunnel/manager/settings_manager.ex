defmodule RitCLI.Tunnel.SettingsManager do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Meta.Error

  @spec extract(Meta.t(), String.t()) :: {:ok, map} | {:error, Meta.t()}
  def extract(meta, path) do
    with {:ok, file_path} <- get_file_path(path),
         {:ok, settings} <- read_settings(file_path) do
      {:ok, settings}
    else
      {:error, error} -> {:error, failed_to_extract_error(meta, error)}
    end
  end

  defp get_file_path(path) do
    file_path = "#{path}/tunnel.yml"

    if File.exists?(file_path) do
      {:ok, file_path}
    else
      file_path = "#{path}/tunnel.yaml"

      if File.exists?(file_path) do
        {:ok, file_path}
      else
        {:error, file_not_found_error(path)}
      end
    end
  end

  defp read_settings(file_path) do
    [settings] = YamlElixir.read_all_from_file!(file_path)
    {:ok, settings}
  rescue
    _error -> {:error, invalid_file_error()}
  end

  defp file_not_found_error(path) do
    Error.build(
      __MODULE__,
      :settings_not_found,
      "referenced settings file on source directory does not exists",
      path: path
    )
  end

  defp invalid_file_error do
    Error.build(
      __MODULE__,
      :settings_invalid,
      "referenced settings file on source directory is not a valid YAML rit settings file"
    )
  end

  defp failed_to_extract_error(meta, error), do: Meta.error(meta, error)
end

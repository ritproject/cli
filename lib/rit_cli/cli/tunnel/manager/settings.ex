defmodule RitCLI.CLI.Tunnel.Manager.Settings do
  @moduledoc false

  alias RitCLI.CLI.{Error, Output}

  @id :tunnel_settings

  @spec extract(String.t()) :: {:ok, map} | {:error, atom, Output.t()}
  def extract(path) do
    case get_file_path(path) do
      {:ok, file} ->
        [settings] = YamlElixir.read_all_from_file!(file)
        {:ok, settings}

      error ->
        error
    end
  rescue
    _error -> Error.build_error(@id, :invalid_yaml)
  end

  defp get_file_path(source_path) do
    path = "#{source_path}/tunnel.yml"

    if File.exists?(path) do
      {:ok, path}
    else
      path = "#{source_path}/tunnel.yaml"

      if File.exists?(path) do
        {:ok, path}
      else
        Error.build_error(@id, :not_found)
      end
    end
  end
end

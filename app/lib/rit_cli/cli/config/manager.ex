defmodule RitCLI.CLI.Config.Manager do
  @moduledoc false

  alias RitCLI.CLI.Output

  @rit_dir ".rit"
  @config_dir "#{@rit_dir}/config"

  @spec get_config(binary()) :: map()
  def get_config(context) do
    path = get_config_path(context)

    File.mkdir_p(Path.dirname(path))
    File.touch(path)

    with {:ok, file_data} <- File.read(path),
         {:ok, config} <- Jason.decode(file_data, keys: :atoms) do
      config
    else
      _error -> %{}
    end
  end

  @spec save_config(binary(), map()) :: :ok | {:error, atom(), Output.t()}
  def save_config(context, config) do
    with {:ok, file_data} <- Jason.encode(config),
         :ok <- File.write(get_config_path(context), file_data) do
      :ok
    else
      _error ->
        {
          :error,
          :failed_to_save_config,
          %Output{error: "Failed to save config for '#{context}'"}
        }
    end
  end

  @spec clear_config(binary()) :: :ok | {:error, atom()}
  def clear_config(context) do
    case File.rm(get_config_path(context)) do
      {:error, :enoent} -> :ok
      result -> result
    end
  end

  defp get_config_path(context) do
    home = System.get_env("HOME", "")
    "#{home}/#{@config_dir}/#{context}.json"
  end
end

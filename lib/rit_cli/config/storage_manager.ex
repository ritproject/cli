defmodule RitCLI.Config.StorageManager do
  @moduledoc false

  alias RitCLI.Meta.Error

  @rit_dir ".rit"
  @config_dir "#{@rit_dir}/config"

  @spec get_storage(String.t()) :: map
  def get_storage(context) do
    path = get_storage_path(context)

    File.mkdir_p(Path.dirname(path))
    File.touch(path)

    with {:ok, file_data} <- File.read(path),
         {:ok, storage} <- Jason.decode(file_data, keys: :atoms) do
      storage
    else
      _error -> %{}
    end
  end

  @spec save_storage(String.t(), map) :: :ok | {:error, Error.t()}
  def save_storage(context, storage) do
    with {:ok, file_data} <- Jason.encode(storage),
         :ok <- File.write(get_storage_path(context), file_data) do
      :ok
    else
      _error -> {:error, save_storage_error()}
    end
  end

  @spec clear_storage(String.t()) :: :ok | {:error, Error.t()}
  def clear_storage(context) do
    case File.rm(get_storage_path(context)) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      _error -> {:error, clear_storage_error()}
    end
  end

  defp get_storage_path(context) do
    home = System.get_env("HOME", "")
    "#{home}/#{@config_dir}/#{context}.json"
  end

  defp save_storage_error do
    Error.build(
      __MODULE__,
      :failed_to_save_config,
      "could not write the config data"
    )
  end

  defp clear_storage_error do
    Error.build(
      __MODULE__,
      :failed_to_clear_config,
      "could not perform operation on config data"
    )
  end
end

defmodule Rit.CLI.Config.Server do
  @moduledoc false

  alias Rit.CLI.Config.ServerManager

  @rit_dir ".rit"
  @config_dir "#{@rit_dir}/config"
  @server_config_path "#{@config_dir}/server.yml"

  def get(operation) do
    get nil, operation
  end

  def get(data, operation) do
    with {:ok, path} <- get_path(@server_config_path),
         {:ok, config} <- get_config(path) do
      perform_operation(config, data, operation)
    end
  end

  def update(data, operation) do
    with {:ok, path} <- get_path(@server_config_path),
         {:ok, config} <- get_config(path),
         {:ok, config} <- perform_operation(config, data, operation) do
      update_config(config, path)
    end
  end

  defp perform_operation(config, data, operation) do
    case operation do
      :list_servers -> ServerManager.list_servers config
      :show_server -> ServerManager.show_server config, data
      :add_server -> ServerManager.add_server config, data
      :edit_server -> ServerManager.edit_server config, data
      :remove_server -> ServerManager.remove_server config, data
      :set_default_server -> ServerManager.set_default_server config, data
      :unset_default_server -> ServerManager.unset_default_server config, data
      _ -> {:error, :unknown_operation, operation}
    end
  end

  defp get_path(path) do
    home = System.get_env("HOME", "")
    {:ok, "#{home}/#{path}"}
  end

  defp get_config(path) do
    File.mkdir_p Path.dirname(path)
    File.touch path

    with {:ok, file_data} <- File.read(path),
         {:ok, config} <- Jason.decode(file_data, keys: :atoms) do
      {:ok, config}
    else
      {:error, %Jason.DecodeError{}} -> {:ok, %{}}
      error -> error
    end
  end

  defp update_config(config, path) do
    with {:ok, file_data} <- Jason.encode(config),
         :ok <- File.write(path, file_data) do
      {:ok, config}
    end
  end
end

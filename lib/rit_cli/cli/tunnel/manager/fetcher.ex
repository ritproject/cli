defmodule RitCLI.CLI.Tunnel.Manager.Fetcher do
  @moduledoc false

  alias RitCLI.CLI.{Config, Error, Git, Output}

  @id :tunnel_fetcher

  @spec fetch(Config.Tunnel.t(), String.t()) :: {:ok, String.t()} | {:error, atom, Output.t()}
  def fetch(%Config.Tunnel{} = config, tunnel_path) do
    case get_default_tunnel_config(config) do
      {:ok, tunnel_config} -> do_fetch(tunnel_config, tunnel_path)
      error -> error
    end
  end

  defp get_default_tunnel_config(%Config.Tunnel{} = config, path \\ ".") do
    path =
      if path == "*" do
        :*
      else
        String.to_atom(Path.expand(path))
      end

    case Map.get(config.defaults, path) do
      nil ->
        if path == :* do
          Error.build_error(@id, :default_not_set)
        else
          get_default_tunnel_config(config, "*")
        end

      name ->
        get_tunnel_config(config, name)
    end
  end

  defp get_tunnel_config(%Config.Tunnel{} = config, name) do
    case Map.get(config.tunnels, String.to_atom(name)) do
      %{from: from, reference: reference} ->
        {:ok, %{from: from, name: name, reference: reference}}

      _nil ->
        Error.build_error(@id, :config_undefined, name: name)
    end
  end

  defp do_fetch(%{from: "local", name: name, reference: reference}, tunnel_path) do
    if File.exists?(reference) do
      path = tunnel_path <> "/" <> name

      File.rmdir(path)
      File.mkdir_p!(path)

      File.cp_r!(reference, path)

      {:ok, path}
    else
      Error.build_error(@id, :local_reference_undefined, name: name, path: reference)
    end
  rescue
    _error -> Error.build_error(@id, :local_reference_fetch_failed, name: name, path: reference)
  end

  defp do_fetch(%{from: "repo", name: name, reference: reference}, tunnel_path) do
    path = "#{tunnel_path}/#{name}"

    case fetch_from_repo(reference, path) do
      {:ok, _result, 0} ->
        {:ok, path}

      _error ->
        File.rm_rf(path)
        Error.build_error(@id, :repo_fetch_failed, name: name, link: reference)
    end
  end

  defp fetch_from_repo(reference, path) do
    if File.exists?(path) do
      File.cd!(path, fn -> Git.run(~w(pull origin master)) end)
    else
      File.mkdir_p(path)
      File.cd!(path, fn -> Git.run(~w(clone #{reference} .)) end)
    end
  end
end

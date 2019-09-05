defmodule RitCLI.CLI.Tunnel.Manager do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Tunnel.Manager.{Fetcher, Runner, Settings}

  @rit_dir ".rit"
  @tunnel_dir "#{@rit_dir}/tunnel"

  @spec fetch_source :: {:ok, String.t()} | {:error, atom, Output.t()}
  def fetch_source do
    Fetcher.fetch(Config.Tunnel.get_config(), get_tunnel_path())
  end

  @spec extract_settings(String.t()) :: {:ok, map} | {:error, atom, Output.t()}
  def extract_settings(path) do
    Settings.extract(path)
  end

  @spec run(map, list(String.t()), String.t()) :: :ok | {:error, atom, Output.t()}
  def run(settings, arguments, source_path) do
    Runner.run(settings, arguments, source_path)
  end

  defp get_tunnel_path do
    home = System.get_env("HOME", "")
    "#{home}/#{@tunnel_dir}"
  end
end

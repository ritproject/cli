defmodule RitCLITest.RitCLI.CLI.Tunnel.Manager.FetcherTest do
  use ExUnit.Case, async: false

  alias RitCLI.CLI.Config
  alias RitCLI.CLI.Tunnel.Manager.Fetcher

  describe "fetch/2" do
    test "return error tuple if failed to fetch" do
      File.rm_rf("/test")
      File.mkdir_p("/test")

      config = %Config.Tunnel{
        tunnels: %{test: %{from: "local", reference: "/test"}},
        defaults: %{*: "test"}
      }

      tunnel_path = nil

      {:error, error_id, _output} = Fetcher.fetch(config, tunnel_path)

      assert error_id == :local_reference_fetch_failed
    end
  end
end

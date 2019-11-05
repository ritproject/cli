defmodule RitCLITest.RitCLI.Tunnel.SourceManagerTest do
  use ExUnit.Case

  alias RitCLI.Meta
  alias RitCLI.Tunnel.SourceManager
  alias RitCLITest.CLIUtils

  import ExUnit.CaptureIO

  describe "SourceManager.fetch/1" do
    test "expose create directory failure" do
      meta = %Meta{
        tunnel: %{
          config: %{from: "local", reference: "/test"}
        }
      }

      path = System.get_env("HOME", "") <> "/.rit"

      File.rm_rf!(path)
      File.mkdir!("/test")
      File.mkdir_p!(path)
      File.write(path <> "/tunnel_sources", "I will block")

      try do
        operation = fn ->
          assert {:error, %Meta{}} = SourceManager.fetch(meta)
        end

        assert capture_io(operation) ==
                 CLIUtils.error_output(
                   :failed_to_source,
                   "OS filesystem command reported a failure\n"
                 )
      after
        File.rm_rf!(path)
        File.rmdir!("/test")
      end
    end

    test "expose unknown default config error" do
      meta = %Meta{
        tunnel: %{
          config: nil,
          path: "/unknown"
        }
      }

      operation = fn ->
        assert {:error, %Meta{}} = SourceManager.fetch(meta)
      end

      assert capture_io(operation) ==
               CLIUtils.error_output(
                 :tunnel_default_config_not_found,
                 "tunnel global default config does not exists\n"
               )
    end
  end
end

defmodule RitCLITest.CLI.Config.Tunnel.ListTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel list

  Show all tunnels configured on your machine.

  """

  describe "command: rit config tunnel list" do
    test "show a list of configured tunnels and defaults" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel add local /root)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set root --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel list)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      # Tunnels

      - root: /root (local)
      - test: https://github.com/test (repo)

      ## Default Paths

      - (global): test
      - /app: root


      """

      assert capture_io(execution) == message
    end

    test "show a list of configured tunnels" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel add local /root)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel list)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      # Tunnels

      - root: /root (local)
      - test: https://github.com/test (repo)

      There are no default tunnels configured on your machine

      """

      assert capture_io(execution) == message
    end

    test "help, do: 'rit help config tunnel list'" do
      execution = fn ->
        argv = ~w(config tunnel list help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config tunnel list', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel list unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel list arguments: 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config tunnel l" do
    test "show a list of configured tunnels" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel l)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      There are no tunnels configured on your machine
      """

      assert capture_io(execution) == message
    end
  end
end

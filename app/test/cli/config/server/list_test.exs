defmodule RitCLITest.CLI.Config.Server.ListTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server list

  Show all servers configured on your machine.

  """

  describe "command: rit config server list" do
    test "show a list of configured servers and defaults" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server add test_two http://test-two.com --port 5000)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server set-default test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server set-default test_two --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server list)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      # Servers

      - test: http://test.com
      - test_two: http://test-two.com:5000

      ## Default Paths

      - (global): test
      - /app: test_two


      """

      assert capture_io(execution) == message
    end

    test "show a list of configured servers" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server add test_two http://test-two.com --port 5000)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server list)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      # Servers

      - test: http://test.com
      - test_two: http://test-two.com:5000

      There are no default servers configured on your machine

      """

      assert capture_io(execution) == message
    end

    test "help, do: 'rit help config server list'" do
      execution = fn ->
        argv = ~w(config server list help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config server list', exit 1" do
      execution = fn ->
        argv = ~w(config server list unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server list arguments: 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config server l" do
    test "show a list of configured servers" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server l)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      There are no servers configured on your machine
      """

      assert capture_io(execution) == message
    end
  end
end

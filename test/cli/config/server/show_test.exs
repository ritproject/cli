defmodule RitCLITest.CLI.Config.Server.ShowTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server show <server_name>

  Show a server from your configurations.

  Arguments:
    <server_name>    Name of the server

  """

  describe "command: rit config server show" do
    test "with no arguments, do: 'rit help config server show', exit 1" do
      execution = fn ->
        argv = ~w(config server show)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server show arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config server show'" do
      execution = fn ->
        argv = ~w(config server show help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<server_name>, do: show server from config" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server show test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      - test: http://test.com

      """

      assert capture_io(execution) == message

      execution = fn ->
        argv = ~w(config server add test_two http://test-two.com --port 5000)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server add test_three http://test-3.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server default set test_two)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server default set test_three --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server show test_two)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      - test_two: http://test-two.com:5000
      (global)

      """

      assert capture_io(execution) == message
    end

    test "inexistent server, do: explain not found, exit 1" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server show test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Server 'test' not found
      """

      assert capture_io(execution) == error_message
    end

    test "invalid server name, do: instruct correct server name, exit 1" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server show test2)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <name> argument with value 'test2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config server s" do
    test "with no arguments, do: 'rit help config server show', exit 1" do
      execution = fn ->
        argv = ~w(config server s)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server show arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

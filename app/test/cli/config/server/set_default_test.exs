defmodule RitCLITest.CLI.Config.Server.SetDefaultTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server set-default <server_name>
                                       --path <path>

  Set a server as your default server.

  Arguments:
    <server_name>    Name of the server

  Option:
    --path    Path where the default server will be set. If blank, the server
              will be interpreted as global default

  """

  describe "command: rit config server set-default" do
    test "with no arguments, do: 'rit help config server set-default', exit 1" do
      execution = fn ->
        argv = ~w(config server set-default)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server set-default arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config server set-default'" do
      execution = fn ->
        argv = ~w(config server set-default help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<server_name>, do: set server as global default" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server set-default test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully set as default
      """

      assert capture_io(execution) == message
    end

    test "<server_name> --path <path>, do: set server as path default" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server set-default test --path .)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully set as default
      """

      assert capture_io(execution) == message
    end

    test "inexistent server, do: explain not found, exit 1" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server set-default test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Server 'test' not found
      """

      assert capture_io(execution) == error_message
    end

    test "invalid server name, do: instruct correct server name, exit 1" do
      execution = fn ->
        argv = ~w(config server set-default test2)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <server_name> argument with value 'test2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end

    test "<server_name> --path <unknown_path>, do: instruct correct path, exit 1" do
      execution = fn ->
        argv = ~w(config server set-default test --path /unknown_folder)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <server_path> argument with value '/unknown_folder' must be a valid path
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config server sd" do
    test "with no arguments, do: 'rit help config server set-default', exit 1" do
      execution = fn ->
        argv = ~w(config server sd)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server set-default arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

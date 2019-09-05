defmodule RitCLITest.CLI.Config.Server.AddTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server add <server_name>
                               <server_hostname>
                               --port <server_port>

  Add a new server to your configurations.

  Arguments:
    <server_name>        A name for the new server
    <server_hostname>    A valid access link to the server

  Option:
    --port               The port of the server, defaults to 80

  """

  describe "command: rit config server add" do
    test "with no arguments, do: 'rit help config server add', exit 1" do
      execution = fn ->
        argv = ~w(config server add)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server add arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config server add'" do
      execution = fn ->
        argv = ~w(config server add help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<server_name> <server_hostname>, do: add server to config" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully added
      """

      assert capture_io(execution) == message
    end

    test "<server_name> <server_hostname> --port <server_port>, do: add server to config" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com --port 5000)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully added
      """

      assert capture_io(execution) == message
    end

    test "<server_name>, do: 'rit help config server add', exit 1" do
      execution = fn ->
        argv = ~w(config server add test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server add arguments: 'test'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "<too_short_server_name> <server_hostname>, do: instruct correct <server_name>, exit 1" do
      execution = fn ->
        argv = ~w(config server add t http://test.com)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <name> argument with value 't' must have at least 2 and at most 20 characters
      """

      assert capture_io(execution) == error_message
    end

    test "<invalid_server_name> <server_hostname>, do: instruct correct <server_name>, exit 1" do
      execution = fn ->
        argv = ~w(config server add t2 http://test.com)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <name> argument with value 't2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end

    test "duplicated server, do: explain uniqueness, exit 1" do
      assert Server.clear_config() == :ok

      argv = ~w(config server add test http://test.com)

      execution = fn ->
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Server 'test' already exists
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config server a" do
    test "with no arguments, do: 'rit help config server add', exit 1" do
      execution = fn ->
        argv = ~w(config server a)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server add arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

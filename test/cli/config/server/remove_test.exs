defmodule RitCLITest.CLI.Config.Server.RemoveTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server remove <server_name>

  Remove a server from your configurations.

  Argument:
    <server_name>    Name of the server

  """

  describe "command: rit config server remove" do
    test "with no arguments, do: 'rit help config server remove', exit 1" do
      execution = fn ->
        argv = ~w(config server remove)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server remove arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config server remove'" do
      execution = fn ->
        argv = ~w(config server remove help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<server_name>, do: remove server from config" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server add test_two http://test-two.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server default set test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server default set test_two --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server remove test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully removed
      """

      assert capture_io(execution) == message
    end

    test "inexistent server, do: explain not found, exit 1" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server remove test)
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
        argv = ~w(config server remove test2)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <name> argument with value 'test2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config server r" do
    test "with no arguments, do: 'rit help config server remove', exit 1" do
      execution = fn ->
        argv = ~w(config server r)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server remove arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

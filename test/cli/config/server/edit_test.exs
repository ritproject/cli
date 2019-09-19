defmodule RitCLITest.CLI.Config.Server.EditTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server edit <server_current_name>
                                --name <server_name>
                                --hostname <server_hostname>
                                --port <server_port>

  Change the info of a server in your configurations.

  Argument:
    <server_name>    Name of the server

  Options (at least one must be defined):
    --name           Update server name
    --hostname       Update server hostname
    --port           Update server port

  """

  describe "command: rit config server edit" do
    test "with no arguments, do: 'rit help config server edit', exit 1" do
      execution = fn ->
        argv = ~w(config server edit)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server edit arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "with unknown option, do: 'rit help config server edit', exit 1" do
      execution = fn ->
        argv = ~w(config server edit test --unknown option)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server edit arguments: 'test --unknown option'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config server edit'" do
      execution = fn ->
        argv = ~w(config server edit help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<server_name> --name <name>, do: edit a server name" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server default set test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server add test_two http://testtwo.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server default set test_two --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server edit test --name test_modified)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test_modified' (previously named 'test') successfully updated
      """

      assert capture_io(execution) == message
    end

    test "<server_name> --hostname <hostname>, do: edit a server hostname" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server edit test --hostname http://testmodified.com)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully updated
      """

      assert capture_io(execution) == message
    end

    test "<server_name> --port <port>, do: edit a server port" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server edit test --port 5000)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Server 'test' successfully updated
      """

      assert capture_io(execution) == message
    end

    test "<server_name>, do: explain about options restriction, exit 1" do
      execution = fn ->
        argv = ~w(config server edit test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: expects at least one of the optional inputs: <name>, <hostname>, <port>
      """

      assert capture_io(execution) == error_message
    end

    test "<server_name> --hostname <invalid_hostname_length>, do: instruct correct <hostname>, exit 1" do
      execution = fn ->
        crazy_long_hostname =
          "http://test.com/I-met-a-traveller-from-an-antique-land-Who-said-Two-vast-and-trunkless-legs-of-stone-Stand-in-the-desert-Near-them-on-the-sand-Half-sunk-a-shattered-visage-lies-whose-frown"

        argv = ~w(config server edit test --hostname #{crazy_long_hostname})
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <hostname> argument with value 'http://test.com/I-met-a-traveller-from-an-antique-land-Who-said-Two-vast-and-trunkless-legs-of-stone-Stand-in-the-desert-Near-them-on-the-sand-Half-sunk-a-shattered-visage-lies-whose-frown' must have at most 150 characters
      """

      assert capture_io(execution) == error_message
    end

    test "<server_name> --hostname <invalid_hostname>, do: instruct correct <hostname>, exit 1" do
      execution = fn ->
        invalid_hostname = ~s(not.hostname)

        argv = ~w(config server edit test --hostname #{invalid_hostname})
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <hostname> argument with value 'not.hostname' must be a valid hostname, with http or https prefix and no trailing slash
      """

      assert capture_io(execution) == error_message
    end

    test "<server_name> --port <invalid_port>, do: instruct correct <port>, exit 1" do
      execution = fn ->
        argv = ~w(config server edit test --port not_a_port)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <port> argument with value 'not_a_port' must be a number
      """

      assert capture_io(execution) == error_message
    end

    test "<inexistent_server_name> --name <name>, do: inform not found, exit 1" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server edit test --name test_modified)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Server 'test' not found
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config server e" do
    test "with no arguments, do: 'rit help config server edit', exit 1" do
      execution = fn ->
        argv = ~w(config server e)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config server edit arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

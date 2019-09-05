defmodule RitCLITest.CLI.Config.Tunnel.EditTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel edit <tunnel_current_name>
                                --name <tunnel_name>
                                --from <tunnel_from>
                                --reference <tunnel_reference>

  Change the info of a tunnel in your configurations.

  Argument:
    <tunnel_name>    Name of the tunnel

  Options (at least one must be defined):
    --name           Update tunnel name
    --from           Update tunnel origin source
    --reference      Update tunnel reference

  """

  describe "command: rit config tunnel edit" do
    test "with no arguments, do: 'rit help config tunnel edit', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel edit)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel edit arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "with unknown option, do: 'rit help config tunnel edit', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel edit test --unknown option)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel edit arguments: 'test --unknown option'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel edit'" do
      execution = fn ->
        argv = ~w(config tunnel edit help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<tunnel_name> --name <name>, do: edit a tunnel name" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel add repo http://github.com/test_two)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set test_two --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel edit test --name test_modified)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'test_modified' (previously named 'test') successfully updated
      """

      assert capture_io(execution) == message
    end

    test "<tunnel_name> --from <from> --reference <reference>, do: edit a tunnel from and reference" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/root)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel edit root --from local --reference /root)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'root' successfully updated
      """

      assert capture_io(execution) == message
    end

    test "<tunnel_name>, do: explain about options restriction, exit 1" do
      execution = fn ->
        argv = ~w(config tunnel edit test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: expects at least one of the optional inputs: <from>, <name>, <reference>
      """

      assert capture_io(execution) == error_message
    end

    test "<inexistent_tunnel_name> --name <name>, do: inform not found, exit 1" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel edit test --name test_modified)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel 'test' not found
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config tunnel e" do
    test "with no arguments, do: 'rit help config tunnel edit', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel e)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel edit arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

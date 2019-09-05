defmodule RitCLITest.CLI.Config.Tunnel.RemoveTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel remove <tunnel_name>

  Remove a tunnel from your configurations.

  Argument:
    <tunnel_name>    Name of the tunnel

  """

  describe "command: rit config tunnel remove" do
    test "with no arguments, do: 'rit help config tunnel remove', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel remove)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel remove arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel remove'" do
      execution = fn ->
        argv = ~w(config tunnel remove help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<tunnel_name>, do: remove tunnel from config" do
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
        argv = ~w(config tunnel remove test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'test' successfully removed
      """

      assert capture_io(execution) == message
    end

    test "inexistent tunnel, do: explain not found, exit 1" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel remove test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel 'test' not found
      """

      assert capture_io(execution) == error_message
    end

    test "invalid tunnel name, do: instruct correct tunnel name, exit 1" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel remove test2)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <name> argument with value 'test2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config tunnel r" do
    test "with no arguments, do: 'rit help config tunnel remove', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel r)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel remove arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

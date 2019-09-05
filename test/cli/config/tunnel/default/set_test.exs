defmodule RitCLITest.CLI.Config.Tunnel.Default.SetTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel default set <tunnel_name>
                                       --path <path>

  Set a tunnel as your default tunnel.

  Arguments:
    <tunnel_name>    Name of the tunnel

  Option:
    --path    Path where the default tunnel will be set. If blank, the tunnel
              will be interpreted as global default

  """

  describe "command: rit config tunnel default set" do
    test "with no arguments, do: 'rit help config tunnel default set', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default set)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel default set arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel default set'" do
      execution = fn ->
        argv = ~w(config tunnel default set help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<tunnel_name>, do: set tunnel as global default" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel default set test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'test' successfully set as default
      """

      assert capture_io(execution) == message
    end

    test "<tunnel_name> --path <path>, do: set tunnel as path default" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel default set test --path .)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'test' successfully set as default
      """

      assert capture_io(execution) == message
    end

    test "inexistent tunnel, do: explain not found, exit 1" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel default set test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel 'test' not found
      """

      assert capture_io(execution) == error_message
    end

    test "invalid tunnel name, do: instruct correct tunnel name, exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default set test2)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <name> argument with value 'test2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end

    test "<tunnel_name> --path <unknown_path>, do: instruct correct path, exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default set test --path /unknown_folder)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <path> argument with value '/unknown_folder' must be a valid path
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config tunnel default s" do
    test "with no arguments, do: 'rit help config tunnel default set', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default s)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel default set arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

defmodule RitCLITest.CLI.Config.Server.UnsetDefaultTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Server

  @helper_message """
  usage: rit config server unset-default --path <path>

  Unset a default server.

  Option:
    --path    Path where the default server was set. If blank, unset global

  """

  describe "command: rit config server unset-default" do
    test "with no arguments and global default set, do: unset global default" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server set-default test)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server unset-default)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Default global server successfully unset
      """

      assert capture_io(execution) == message
    end

    test "help, do: 'rit help config server unset-default'" do
      execution = fn ->
        argv = ~w(config server unset-default help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "--path <path>, do: unset default on path" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server add test http://test.com)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config server set-default test --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config server unset-default --path .)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Default server from '/app' path successfully unset
      """

      assert capture_io(execution) == message
    end

    test "--path <unknown_path>, do: instruct correct path, exit 1" do
      execution = fn ->
        argv = ~w(config server unset-default --path /unknown_folder)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <server_path> argument with value '/unknown_folder' must be a valid path
      """

      assert capture_io(execution) == error_message
    end

    test "with unknown argument, do: 'rit help config server unset-default', exit 1" do
      execution = fn ->
        argv = ~w(config server unset-default unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server unset_default arguments: 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config server ud" do
    test "with no arguments and no global default set, do: explain global not set" do
      assert Server.clear_config() == :ok

      execution = fn ->
        argv = ~w(config server ud)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: There are no global default server set
      """

      assert capture_io(execution) == error_message
    end
  end
end

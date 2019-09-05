defmodule RitCLITest.CLI.Config.Tunnel.Default.UnsetTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel default unset --path <path>

  Unset a default tunnel.

  Option:
    --path    Path where the default tunnel was set. If blank, unset global

  """

  describe "command: rit config tunnel default unset" do
    test "with no arguments and global default set, do: unset global default" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set test)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel default unset)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Default global tunnel successfully unset
      """

      assert capture_io(execution) == message
    end

    test "help, do: 'rit help config tunnel default unset'" do
      execution = fn ->
        argv = ~w(config tunnel default unset help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "--path <path>, do: unset default on path" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set test --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel default unset --path .)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Default tunnel from '/app' path successfully unset
      """

      assert capture_io(execution) == message
    end

    test "--path <unknown_path>, do: instruct correct path, exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default unset --path /unknown_folder)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: <path> argument with value '/unknown_folder' must be a valid path
      """

      assert capture_io(execution) == error_message
    end

    test "with unknown argument, do: 'rit help config tunnel default unset', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default unset unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel default unset arguments: 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config tunnel default u" do
    test "with no arguments and no global default set, do: explain global not set" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel default u)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: There are no global default tunnel set
      """

      assert capture_io(execution) == error_message
    end
  end
end

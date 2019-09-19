defmodule RitCLITest.CLI.Config.Tunnel.ShowTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel show <tunnel_name>

  Show a tunnel from your configurations.

  Arguments:
    <tunnel_name>    Name of the tunnel

  """

  describe "command: rit config tunnel show" do
    test "with no arguments, do: 'rit help config tunnel show', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel show)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config tunnel show arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel show'" do
      execution = fn ->
        argv = ~w(config tunnel show help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "<tunnel_name>, do: show tunnel from config" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://github.com/test)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel show test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      - test: https://github.com/test (repo)

      """

      assert capture_io(execution) == message

      execution = fn ->
        argv = ~w(config tunnel add local /root)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel add repo https://gitlab.com/test_two)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set root)
        assert RitCLI.main(argv) == :ok

        argv = ~w(config tunnel default set test_two --path .)
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(config tunnel show root)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      - root: /root (local)
      (global)

      """

      assert capture_io(execution) == message
    end

    test "inexistent tunnel, do: explain not found, exit 1" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel show test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Tunnel 'test' not found
      """

      assert capture_io(execution) == error_message
    end

    test "invalid tunnel name, do: instruct correct tunnel name, exit 1" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel show test2)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <name> argument with value 'test2' must start and finish with a letter and must contain only letters and underscore
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config tunnel s" do
    test "with no arguments, do: 'rit help config tunnel show', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel s)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config tunnel show arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

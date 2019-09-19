defmodule RitCLITest.CLI.Config.Tunnel.AddTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias RitCLI.CLI.Config.Tunnel

  @helper_message """
  usage: rit config tunnel add <tunnel_from>
                               <tunnel_reference>
                               --name <tunnel_name>

  Add a new tunnel to your configurations.

  Arguments:
    <tunnel_from>         Origin of the tunnel source
                          Options:
                            repo:  From a git remote repository
                                   Reference must be an URL
                            local: From a local directory
                                   Reference must be a valid path
    <tunnel_reference>    A valid reference for the source

  Option:
    --name                A name for the new tunnel, defaults to the last
                          segment of <tunnel_reference>

  """

  describe "command: rit config tunnel add" do
    test "with no arguments, do: 'rit help config tunnel add', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel add)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config tunnel add arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel add'" do
      execution = fn ->
        argv = ~w(config tunnel add help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "repo <tunnel_reference>, do: add tunnel to config" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo http://github.com/test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'test' successfully added
      """

      assert capture_io(execution) == message
    end

    test "local <tunnel_reference>, do: add tunnel to config" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add local /root)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'root' successfully added
      """

      assert capture_io(execution) == message
    end

    test "<tunnel_from> <tunnel_reference> --name <tunnel_name>, do: add tunnel to config" do
      assert Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add local / --name test)
        assert RitCLI.main(argv) == :ok
      end

      message = """
      Tunnel 'test' successfully added
      """

      assert capture_io(execution) == message
    end

    test "<tunnel_from>, do: 'rit help config tunnel add', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel add repo)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config tunnel add arguments: 'repo'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end

    test "<unknown_tunnel_from> <tunnel_reference>, do: instruct correct <tunnel_from>, exit 1" do
      execution = fn ->
        argv = ~w(config tunnel add from https://github.com/test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: <from> argument with value 'from' must be 'local' or 'repo'
      """

      assert capture_io(execution) == error_message
    end

    test "duplicated tunnel, do: explain uniqueness, exit 1" do
      assert Tunnel.clear_config() == :ok

      argv = ~w(config tunnel add repo https://github.com/test)

      execution = fn ->
        assert RitCLI.main(argv) == :ok
      end

      capture_io(execution)

      execution = fn ->
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Tunnel 'test' already exists
      """

      assert capture_io(execution) == error_message
    end
  end

  describe "command: rit config tunnel a" do
    test "with no arguments, do: 'rit help config tunnel add', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel a)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown config tunnel add arguments: ''
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end
end

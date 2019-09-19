defmodule RitCLITest.CLI.HelpTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @helper_message """
  usage: rit <context> [arguments]

  Perform operations that improve your development and requirements management.

  Available contexts:
    a, auth      Perform authentication operations to a RitServer
    c, config    Configuration operations
    h, help      Guidance about rit usage
    g, git       Use your 'git' command
    t, tunnel    Bind utility for directories and repos

  """

  @helper_config_message """
  usage: rit config <context> [arguments]

  Perform operations on your rit configuration files.

  Available config contexts:
    h, help               Guidance about rit config usage
    s, server, servers    Manage your server integration configuration
    t, tunnel, tunnels    Manage your tunnel configuration

  """

  describe "command: rit help" do
    test "with no arguments, do: show helper for 'rit'" do
      execution = fn ->
        argv = ~w(help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "context, do: show helper for context" do
      execution = fn ->
        argv = ~w(help config)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_config_message
    end

    test "with unknown context, do: 'rit', exit 1" do
      execution = fn ->
        argv = ~w(help unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      \e[31mError\e[0m: Unknown context 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit h" do
    test "with no arguments, do: 'rit help config', exit 1" do
      execution = fn ->
        argv = ~w(h)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end
  end
end

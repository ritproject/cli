defmodule RitCLITest.CLI.ConfigTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No config context defined
  """

  @helper_message """
  usage: rit config <context> [arguments]

  Perform operations on your rit configuration files.

  Available config contexts:
    h, help               Guidance about rit config usage
    s, server, servers    Manage your server integration configuration

  """

  describe "command: rit config" do
    test "with no arguments, do: 'rit help config', exit 1" do
      execution = fn ->
        argv = ~w(config)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end

    test "help, do: 'rit help config'" do
      execution = fn ->
        argv = ~w(config help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config', exit 1" do
      execution = fn ->
        argv = ~w(config unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config context 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit c" do
    test "with no arguments, do: 'rit help config', exit 1" do
      execution = fn ->
        argv = ~w(c)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

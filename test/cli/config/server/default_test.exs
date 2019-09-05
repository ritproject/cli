defmodule RitCLITest.CLI.Config.Server.DefaultTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No config server default operation defined
  """

  @helper_message """
  usage: rit config server default <operation> [arguments]

  Manage default server configuration.

  Available operations:
    s, set      Set a server as your default server
    u, unset    Unset a default server from a path

  """

  describe "command: rit config server default" do
    test "with no arguments, do: 'rit help config server default', exit 1" do
      execution = fn ->
        argv = ~w(config server default)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end

    test "help, do: 'rit help config server default'" do
      execution = fn ->
        argv = ~w(config server default help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config server default', exit 1" do
      execution = fn ->
        argv = ~w(config server default unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server default operation 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config d" do
    test "with no arguments, do: 'rit help config server default', exit 1" do
      execution = fn ->
        argv = ~w(config server d)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

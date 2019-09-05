defmodule RitCLITest.CLI.Config.Tunnel.DefaultTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No config tunnel default operation defined
  """

  @helper_message """
  usage: rit config tunnel default <operation> [arguments]

  Manage default tunnel configuration.

  Available operations:
    s, set      Set a tunnel as your default tunnel
    u, unset    Unset a default tunnel from a path

  """

  describe "command: rit config tunnel default" do
    test "with no arguments, do: 'rit help config tunnel default', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel default'" do
      execution = fn ->
        argv = ~w(config tunnel default help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config tunnel default', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel default unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel default operation 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config d" do
    test "with no arguments, do: 'rit help config tunnel default', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel d)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

defmodule RitCLITest.CLI.Config.TunnelTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No config tunnel operation defined
  """

  @helper_message """
  usage: rit config tunnel <operation> [arguments]

  Manage your tunnel configuration.

  Available operations:
    a, add               Add a new tunnel to your configurations
    d, default           Manage default tunnel configuration
    e, edit              Change the info of a tunnel in your configurations
    h, help              Guidance about rit config tunnel usage
    l, list              Show all tunnels configured on your machine
    r, remove            Remove a tunnel from your configurations
    s, show              Show a tunnel from your configurations

  """

  describe "command: rit config tunnel" do
    test "with no arguments, do: 'rit help config tunnel', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end

    test "help, do: 'rit help config tunnel'" do
      execution = fn ->
        argv = ~w(config tunnel help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config tunnel', exit 1" do
      execution = fn ->
        argv = ~w(config tunnel unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config tunnel operation 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config tunnels" do
    test "with no arguments, do: 'rit help config tunnel', exit 1" do
      execution = fn ->
        argv = ~w(config tunnels)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end

  describe "command: rit config t" do
    test "with no arguments, do: 'rit help config tunnel', exit 1" do
      execution = fn ->
        argv = ~w(config t)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

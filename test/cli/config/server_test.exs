defmodule RitCLITest.CLI.Config.ServerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No config server operation defined
  """

  @helper_message """
  usage: rit config server <operation> [arguments]

  Manage your server integration configuration.

  Available operations:
    a, add               Add a new server to your configurations
    d, default           Manage default server configuration
    e, edit              Change the info of a server in your configurations
    h, help              Guidance about rit config server usage
    l, list              Show all servers configured on your machine
    r, remove            Remove a server from your configurations
    s, show              Show a server from your configurations

  """

  describe "command: rit config server" do
    test "with no arguments, do: 'rit help config server', exit 1" do
      execution = fn ->
        argv = ~w(config server)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end

    test "help, do: 'rit help config server'" do
      execution = fn ->
        argv = ~w(config server help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help config server', exit 1" do
      execution = fn ->
        argv = ~w(config server unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown config server operation 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit config servers" do
    test "with no arguments, do: 'rit help config server', exit 1" do
      execution = fn ->
        argv = ~w(config servers)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end

  describe "command: rit config s" do
    test "with no arguments, do: 'rit help config server', exit 1" do
      execution = fn ->
        argv = ~w(config s)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

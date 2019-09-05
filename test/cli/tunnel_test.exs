defmodule RitCLITest.CLI.TunnelTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No tunnel context defined
  """

  @helper_message """
  usage: rit tunnel <context> [arguments]

  Bind external directory into current directory and perform operations

  Available contexts:
    h, help    Guidance about rit usage
    r, run     Run operation defined on default tunnel config directory

  """

  describe "command: rit tunnel" do
    test "with no arguments, do: 'rit help tunnel', exit 1" do
      execution = fn ->
        argv = ~w(tunnel)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end

    test "help, do: 'rit help tunnel'" do
      execution = fn ->
        argv = ~w(tunnel help)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == @helper_message
    end

    test "with unknown argument, do: 'rit help tunnel', exit 1" do
      execution = fn ->
        argv = ~w(tunnel unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Unknown tunnel context 'unknown'
      """

      assert capture_io(execution) == error_message <> @helper_message
    end
  end

  describe "command: rit t" do
    test "with no arguments, do: 'rit help tunnel', exit 1" do
      execution = fn ->
        argv = ~w(t)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

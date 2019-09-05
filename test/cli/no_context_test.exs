defmodule RitCLITest.CLI.NoContextTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @error_message """
  Error: No context defined
  """

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

  describe "command: rit" do
    test "with no arguments, do: 'rit help', exit 1" do
      execution = fn ->
        assert catch_exit(RitCLI.main([])) == {:shutdown, 1}
      end

      assert capture_io(execution) == @error_message <> @helper_message
    end
  end
end

defmodule RitCLITest.CLI.GitTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  describe "command: rit git" do
    test "run git normally" do
      {git_result, 0} = System.cmd("git", ["version"])

      execution = fn ->
        argv = ~w(git version)
        assert RitCLI.main(argv) == :ok
      end

      assert capture_io(execution) == git_result <> "\n"
    end
  end

  describe "command: rit g" do
    test "run git normally" do
      {git_result, 1} = System.cmd("git", [])

      execution = fn ->
        argv = ~w(g)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      assert capture_io(execution) == "\e[31mError\e[0m: " <> git_result <> "\n"
    end
  end
end

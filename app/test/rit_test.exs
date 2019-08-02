defmodule RitTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  describe "Rit.main/1" do
    test "Runs git when it has git argument as context" do
      {git_result, git_exit_code} = System.cmd("git", [])

      execution = fn ->
        assert catch_exit(Rit.main(["git"])) == {:shutdown, git_exit_code}
      end

      assert capture_io(execution) == git_result <> "\n"
    end

    test "Runs git when it has g argument as context" do
      {git_result, git_exit_code} = System.cmd("git", ["version"])

      execution = fn ->
        assert catch_exit(Rit.main(["g", "version"])) == {:shutdown, git_exit_code}
      end

      assert capture_io(execution) == git_result <> "\n"
    end

    test "Fails gracefully if a list of strict strings are not given" do
      execution = fn ->
        assert catch_exit(Rit.main(["git", nil])) == {:shutdown, 1}
      end

      assert capture_io(execution) == "Error Git Failed To Run \n"
    end

    test "Fails gracefully if has an unknown argument as context" do
      execution = fn ->
        assert catch_exit(Rit.main(["unknown"])) == {:shutdown, 1}
      end

      assert capture_io(execution) == "Error Unknown Context unknown\n"
    end
  end
end

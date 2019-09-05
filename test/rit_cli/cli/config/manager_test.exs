defmodule RitCLITest.RitCLI.CLI.Config.ManagerTest do
  use ExUnit.Case, async: false

  alias RitCLI.CLI.Config.Manager

  describe "save_config/2" do
    test "return error tuple if failed to save" do
      home = System.get_env("HOME", "")

      assert File.rmdir("#{home}/.rit")

      assert {:error, :failed_to_save_config, %RitCLI.CLI.Output{}} =
               Manager.save_config("test", i_will: "fail")
    end
  end
end

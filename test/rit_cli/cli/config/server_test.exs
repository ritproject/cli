defmodule RitCLITest.RitCLI.CLI.Config.ServerTest do
  use ExUnit.Case, async: false

  alias RitCLI.CLI.Config.Server

  describe "has_server?/1" do
    test "return true if has server" do
      assert Server.clear_config() == :ok

      assert {:ok, config} =
               Server.add_server(%Server.Input.Add{
                 name: "test",
                 hostname: "http://test.com",
                 port: "80"
               })

      assert :ok = Server.save_config(config)

      assert Server.has_server?("test") == true
    end
  end

  describe "get_config/0" do
    test "return struct even if config is dirty" do
      home = System.get_env("HOME", "")

      assert File.rmdir("#{home}/.rit")
      assert File.mkdir_p("#{home}/.rit/config/") == :ok

      assert File.write(
               "#{home}/.rit/config/server.json",
               Jason.encode!(%{not_from_server: "really"})
             ) == :ok

      assert Server.get_config() == %Server{}
    end
  end
end

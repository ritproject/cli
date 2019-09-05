defmodule RitCLITest.RitCLI.CLI.Config.TunnelTest do
  use ExUnit.Case, async: false

  alias RitCLI.CLI.Config.Tunnel

  describe "has_tunnel?/1" do
    test "return true if has tunnel" do
      assert Tunnel.clear_config() == :ok

      assert {:ok, config} =
               Tunnel.add_tunnel(%Tunnel.Input.Add{
                 from: "repo",
                 reference: "https://github.com/test",
                 name: "test"
               })

      assert :ok = Tunnel.save_config(config)

      assert Tunnel.has_tunnel?("test") == true
    end
  end

  describe "get_config/0" do
    test "return struct even if config is dirty" do
      home = System.get_env("HOME", "")

      assert File.rmdir("#{home}/.rit")
      assert File.mkdir_p("#{home}/.rit/config/") == :ok

      assert File.write(
               "#{home}/.rit/config/tunnel.json",
               Jason.encode!(%{not_from_tunnel: "really"})
             ) == :ok

      assert Tunnel.get_config() == %Tunnel{}
    end
  end
end

defmodule RitCLITest.RitCLI.Config.TunnelStorageTest do
  use ExUnit.Case

  alias RitCLI.Config.TunnelStorage

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "TunnelStorage.get_storage/0" do
    test "succeeds even when data is dirty" do
      home = System.get_env("HOME", "")
      File.mkdir_p("#{home}/.rit/config/")

      File.write(
        "#{home}/.rit/config/tunnel.json",
        Jason.encode!(%{not_from_tunnel: "really"})
      )

      assert %TunnelStorage{} = TunnelStorage.get_storage()
    end
  end
end

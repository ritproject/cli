defmodule RitCLITest.CLI.TunnelSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Tunnel

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit t -c <name> | rit tunnel --config <name>]" do
    test "name valid, continue" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()

      setup_cli_test()
      |> add_helper_output(Tunnel)
      |> set_argv(~w(tunnel --config test help))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -c test h))
      |> cli_test()
    end
  end
end

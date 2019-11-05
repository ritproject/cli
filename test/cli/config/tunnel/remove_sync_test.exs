defmodule RitCLITest.CLI.Config.Tunnel.RemoveSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage

  @success "tunnel config 'test' removed"

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit config tunnel remove <name>]" do
    test "valid existing config name, remove config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel remove test))
      |> add_success_output(@success)
      |> cli_test()
    end

    test "remove with multiple defaults, remove config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test_two))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel default set test))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel default set test_two --path /tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel remove test))
      |> add_success_output(@success)
      |> cli_test()
    end
  end
end

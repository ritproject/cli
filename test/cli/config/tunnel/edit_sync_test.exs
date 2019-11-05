defmodule RitCLITest.CLI.Config.Tunnel.EditSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage

  @name_success "tunnel config 'modified_test' (previously named 'test') updated"

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit config tunnel edit <current_name> --name <name>]" do
    test "valid current_name and name, edit config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --name modified_test))
      |> add_success_output(@name_success)
      |> cli_test()
    end

    test "edit with multiple defaults, edit config" do
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
      |> set_argv(~w(config tunnel edit test --name modified_test))
      |> add_success_output(@name_success)
      |> cli_test()
    end
  end
end

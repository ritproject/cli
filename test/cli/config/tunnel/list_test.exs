defmodule RitCLITest.CLI.Config.Tunnel.ListTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.List
  alias RitCLI.Config.TunnelStorage

  @no_configs_set "There are no tunnel configs set"
  @no_configs_set_map inspect(%{data: []})
  @unknown_arguments "only help is allowed as argument"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit config tunnel list]" do
    test "empty message if empty" do
      setup_cli_test()
      |> set_argv(~w(config tunnel list))
      |> add_output(@no_configs_set)
      |> cli_test()
    end

    test "with inspect output mode, show empty map data" do
      setup_cli_test()
      |> set_argv(~w(--output inspect config tunnel list))
      |> add_output(@no_configs_set_map)
      |> cli_test()
    end
  end

  describe "[rit config tunnel list help]" do
    test "show config tunnel default helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel list help))
      |> add_helper_output(List)
      |> cli_test()
    end
  end

  describe "[rit config tunnel list ???]" do
    test "argument invalid, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel list unknown))
      |> set_exit_code(1)
      |> add_error_output(:unknown_arguments, @unknown_arguments)
      |> add_helper_output(List)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t l unknown))
      |> cli_test()
    end
  end
end

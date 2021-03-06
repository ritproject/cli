defmodule RitCLITest.CLI.Config.Tunnel.ListSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage

  @config_set """
  # Tunnels Configs

  - tmp: /tmp (local)

  There are no default tunnel configs set
  """

  @config_set_data %{data: [%{from: :local, name: "tmp", reference: "/tmp"}]}

  @default_set """
  # Tunnels Configs

  - tmp: /tmp (local)

  ## Default Paths

  - (global): tmp

  """

  @default_set_data %{data: [%{from: :local, name: "tmp", paths: [:*], reference: "/tmp"}]}

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit config tunnel list]" do
    test "with config set, show list" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel list))
      |> add_output(@config_set)
      |> cli_test()
    end

    test "with config set and output mode json, show json data" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(--output json config tunnel list))
      |> add_output(Jason.encode!(@config_set_data, pretty: true))
      |> cli_test()
    end

    test "with config and default set, show list" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel list))
      |> add_output(@default_set)
      |> cli_test()
    end

    test "with config and default set, and output mode json, show json data" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(--output json config tunnel list))
      |> add_output(Jason.encode!(@default_set_data, pretty: true))
      |> cli_test()
    end
  end
end

defmodule RitCLITest.CLI.Config.Tunnel.ShowSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage

  @config_set """
  - name: tmp
  - from: local
  - reference: /tmp
  """

  @config_set_data %{data: %{from: :local, name: "tmp", reference: "/tmp"}}

  @default_set """
  - name: tmp
  - from: local
  - reference: /tmp
  - default_paths:
      - (global)
      - /home\
  """

  @default_set_data %{data: %{from: :local, name: "tmp", paths: [:*, "/home"], reference: "/tmp"}}

  @without_default_set_data %{data: %{from: :local, name: "tmp", reference: "/tmp"}}

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit config tunnel show <name>]" do
    test "with config set, show config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel show tmp))
      |> add_output(@config_set)
      |> cli_test()
    end

    test "with config set and output mode ugly_json, show json data" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(--output ugly_json config tunnel show tmp))
      |> add_output(Jason.encode!(@config_set_data))
      |> cli_test()
    end

    test "with config and default set, show config and its paths" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp --path /home))
      |> cli_test()
      |> set_argv(~w(config tunnel default set test --path /app))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel show tmp))
      |> add_output(@default_set)
      |> cli_test()
    end

    test "with config and default set, and output mode json, show json data" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp --path /home))
      |> cli_test()
      |> set_argv(~w(config tunnel default set test --path /app))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(--output json config tunnel show tmp))
      |> add_output(Jason.encode!(@default_set_data, pretty: true))
      |> cli_test()
    end

    test "with config and default set (but not from config selected), and output mode json, show json data" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()
      |> set_argv(~w(config tunnel default set test --path /app))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(--output json config tunnel show tmp))
      |> add_output(Jason.encode!(@without_default_set_data, pretty: true))
      |> cli_test()
    end
  end
end

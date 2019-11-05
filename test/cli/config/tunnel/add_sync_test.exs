defmodule RitCLITest.CLI.Config.Tunnel.AddSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage

  @non_unique_tunnel_config "tunnel config with name 'test' already exists"

  @no_named_success "tunnel config 'tmp' saved"
  @named_success "tunnel config 'test' saved"

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit config tunnel add local <reference>]" do
    test "valid reference, add config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> add_success_output(@no_named_success)
      |> cli_test()
    end
  end

  describe "(sync) [rit config tunnel add repo <reference>]" do
    test "valid reference, add config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add repo http://mygitrepo.com/tmp))
      |> add_success_output(@no_named_success)
      |> cli_test()
    end
  end

  describe "(sync) [rit config tunnel add local <reference> --name <name>]" do
    test "valid reference and name, add config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> add_success_output(@named_success)
      |> cli_test()
    end

    test "duplicated name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name test))
      |> cli_test()
      |> set_exit_code(1)
      |> add_error_output(:non_unique_tunnel_config, @non_unique_tunnel_config)
      |> cli_test()
    end
  end

  describe "(sync) [rit config tunnel add repo <reference> --name <name>]" do
    test "valid reference and name, add config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add repo http://mygitrepo.com/tmp --name test))
      |> add_success_output(@named_success)
      |> cli_test()
    end
  end
end

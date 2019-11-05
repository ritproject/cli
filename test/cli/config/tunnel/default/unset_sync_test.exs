defmodule RitCLITest.CLI.Config.Tunnel.Default.UnsetSyncTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage

  @global_success "unset global default tunnel config"
  @success "unset default tunnel config on path '/home'"

  setup_all do
    TunnelStorage.clear_storage()
  end

  setup do
    on_exit(fn -> TunnelStorage.clear_storage() end)
  end

  describe "(sync) [rit config tunnel default unset]" do
    test "global default set, unset global default config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel default unset))
      |> add_success_output(@global_success)
      |> cli_test()
    end
  end

  describe "(sync) [rit config tunnel default unset --path <path>]" do
    test "default set on valid path, unset default config" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp))
      |> cli_test()
      |> set_argv(~w(config tunnel default set tmp --path /home))
      |> cli_test()

      setup_cli_test()
      |> set_argv(~w(config tunnel default unset --path /home))
      |> add_success_output(@success)
      |> cli_test()
    end
  end

  # describe "(sync) [rit config tunnel default unset repo <reference>]" do
  #   test "valid reference, default unset config" do
  #     setup_cli_test()
  #     |> set_argv(~w(config tunnel default unset repo http://mygitrepo.com/tmp))
  #     |> default unset_success_output(@no_named_success)
  #     |> cli_test()
  #   end
  # end

  # describe "(sync) [rit config tunnel default unset local <reference> --name <name>]" do
  #   test "valid reference and name, default unset config" do
  #     setup_cli_test()
  #     |> set_argv(~w(config tunnel default unset local /tmp --name test))
  #     |> default unset_success_output(@named_success)
  #     |> cli_test()
  #   end

  #   test "duplicated name, show error" do
  #     setup_cli_test()
  #     |> set_argv(~w(config tunnel default unset local /tmp --name test))
  #     |> cli_test()
  #     |> set_exit_code(1)
  #     |> default unset_error_output(:non_unique_tunnel_config, @non_unique_tunnel_config)
  #     |> cli_test()
  #   end
  # end

  # describe "(sync) [rit config tunnel default unset repo <reference> --name <name>]" do
  #   test "valid reference and name, default unset config" do
  #     setup_cli_test()
  #     |> set_argv(~w(config tunnel default unset repo http://mygitrepo.com/tmp --name test))
  #     |> default unset_success_output(@named_success)
  #     |> cli_test()
  #   end
  # end
end

defmodule RitCLITest.CLI.Config.Tunnel.Default.UnsetTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Default.Unset
  alias RitCLI.Config.TunnelStorage

  @argument_invalid_path "argument 'path' with value '/unknown' must be a valid path"
  @not_found "tunnel global default config does not exists"
  @invalid_arguments "only valid --path option is allowed"
  @tunnel_default_config_not_found "tunnel default config on path '/tmp' does not exists"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit c t d u | rit config tunnel default unset]" do
    test "show error and config tunnel default unset helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default unset))
      |> set_exit_code(1)
      |> add_error_output(:tunnel_default_config_not_found, @not_found)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d u))
      |> cli_test()
    end
  end

  describe "[rit c t d u help | rit config tunnel default unset help]" do
    test "show config tunnel default unset helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default unset help))
      |> add_helper_output(Unset)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d u help))
      |> cli_test()
    end
  end

  describe "[rit config tunnel default unset --path <path>]" do
    test "invalid path, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default unset --path /unknown))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_path)
      |> cli_test()
    end

    test "unknown config on path, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default unset --path /tmp))
      |> set_exit_code(1)
      |> add_error_output(:tunnel_default_config_not_found, @tunnel_default_config_not_found)
      |> cli_test()
    end
  end

  describe "[rit config tunnel default unset ???]" do
    test "unknown option, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default unset --unknown option))
      |> set_exit_code(1)
      |> add_error_output(:invalid_arguments, @invalid_arguments)
      |> cli_test()
    end
  end
end

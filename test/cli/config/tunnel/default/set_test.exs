defmodule RitCLITest.CLI.Config.Tunnel.Default.SetTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Default.Set
  alias RitCLI.Config.TunnelStorage

  @argument_invalid_name "argument 'name' with value '42' must start and finish with a letter and must contain only letters and underscore"
  @empty_arguments "at least name must be provided"
  @invalid_arguments "at least a valid name must be provided"
  @tunnel_config_not_found "tunnel config with name 'unknown' does not exists"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit c t d s | rit config tunnel default set]" do
    test "show error and config tunnel default set helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default set))
      |> set_exit_code(1)
      |> add_error_output(:empty_arguments, @empty_arguments)
      |> add_helper_output(Set)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d s))
      |> cli_test()
    end
  end

  describe "[rit c t d s help | rit config tunnel default set help]" do
    test "show config tunnel default set helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default set help))
      |> add_helper_output(Set)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d s help))
      |> cli_test()
    end
  end

  describe "[rit config tunnel default set <name>]" do
    test "invalid name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default set 42))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_name)
      |> cli_test()
    end

    test "unknown config, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default set unknown))
      |> set_exit_code(1)
      |> add_error_output(:tunnel_config_not_found, @tunnel_config_not_found)
      |> cli_test()
    end
  end

  describe "[rit config tunnel default set ???]" do
    test "unknown option, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default set test --unknown option))
      |> set_exit_code(1)
      |> add_error_output(:invalid_arguments, @invalid_arguments)
      |> cli_test()
    end
  end
end

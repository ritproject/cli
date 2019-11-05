defmodule RitCLITest.CLI.Config.Tunnel.EditTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Edit
  alias RitCLI.Config.TunnelStorage

  @argument_invalid_repo_reference "argument 'reference' with value 'unknown' must be a valid hostname, with http or https prefix and no trailing slash"
  @argument_invalid_current_name "argument 'current_name' with value '42' must start and finish with a letter and must contain only letters and underscore"
  @argument_invalid_name "argument 'name' with value '42' must start and finish with a letter and must contain only letters and underscore"
  @argument_invalid_from "argument 'from' with value 'unknown' must be 'local' or 'repo'"
  @empty_arguments "at least current name argument must be provided"
  @empty_options "at least one valid option must be provided"
  @invalid_arguments "only valid current name and options must be provided"
  @reference_without_from "in order to change 'reference', it is required to set 'from' argument"
  @tunnel_config_not_found "tunnel config with name 'test' does not exists"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit c t e | rit config tunnel edit]" do
    test "show error and config tunnel edit helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit))
      |> set_exit_code(1)
      |> add_error_output(:empty_arguments, @empty_arguments)
      |> add_helper_output(Edit)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t e))
      |> cli_test()
    end
  end

  describe "[rit c t e help | rit config tunnel edit help]" do
    test "show config tunnel edit helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit help))
      |> add_helper_output(Edit)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t e help))
      |> cli_test()
    end
  end

  describe "[rit config tunnel edit <name>]" do
    test "invalid name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit 42))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_current_name)
      |> cli_test()
    end

    test "only name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test))
      |> set_exit_code(1)
      |> add_error_output(:empty_options, @empty_options)
      |> cli_test()
    end
  end

  describe "[rit config tunnel edit <name> --from <from>]" do
    test "invalid from, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --from unknown))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_from)
      |> cli_test()
    end
  end

  describe "[rit config tunnel edit <current_name> --name <name>]" do
    test "invalid name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --name 42))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_name)
      |> cli_test()
    end
  end

  describe "[rit config tunnel edit <current_name> --reference <reference>]" do
    test "show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --reference unknown))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @reference_without_from)
      |> cli_test()
    end
  end

  describe "[rit config tunnel edit <current_name> --from from --reference <reference>]" do
    test "invalid reference, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --from repo --reference unknown))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_repo_reference)
      |> cli_test()
    end
  end

  describe "[rit config tunnel edit ???]" do
    test "invalid option, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --unknown unknown))
      |> set_exit_code(1)
      |> add_error_output(:invalid_arguments, @invalid_arguments)
      |> cli_test()
    end

    test "unknown config, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel edit test --name test_invalid))
      |> set_exit_code(1)
      |> add_error_output(:tunnel_config_not_found, @tunnel_config_not_found)
      |> cli_test()
    end
  end
end

defmodule RitCLITest.CLI.TunnelTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Tunnel

  @argument_invalid_path "argument 'path' with value '/unknown/path' must be a valid path"
  @argument_invalid_config "argument 'config' with value '42' must start and finish with a letter and must contain only letters and underscore"
  @empty_command "at least a command must be provided"
  @empty_config_modifier "config name must be provided"
  @empty_input_modifier "input mode must be provided"
  @empty_path_modifier "path must be provided"
  @invalid_command "the command 'unknown' is invalid"
  @invalid_input_mode "the input mode 'unknown' is invalid"
  @invalid_modifier "the modifier 'unknown' is invalid"
  @tunnel_config_not_found "tunnel config with name 'unknown' does not exists"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit t | rit tunnel]" do
    test "show error and tunnel helper" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_command, @empty_command)
      |> add_helper_output(Tunnel)
      |> set_argv(~w(tunnel))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t))
      |> cli_test()
    end
  end

  describe "[rit t h | rit tunnel help]" do
    test "show tunnel helper" do
      setup_cli_test()
      |> set_argv(~w(tunnel help))
      |> add_helper_output(Tunnel)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t h))
      |> cli_test()
    end
  end

  describe "[rit t -c <name> | rit tunnel --config <name>]" do
    test "empty name, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_config_modifier, @empty_config_modifier)
      |> set_argv(~w(tunnel --config))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -c))
      |> cli_test()
    end

    test "invalid config, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_config)
      |> set_argv(~w(tunnel --config 42))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -c 42))
      |> cli_test()
    end

    test "not found config, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:tunnel_config_not_found, @tunnel_config_not_found)
      |> set_argv(~w(tunnel --config unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -c unknown))
      |> cli_test()
    end
  end

  describe "[rit t -i <mode> | rit tunnel --input <mode>]" do
    test "mode valid, continue" do
      setup_cli_test()
      |> add_helper_output(Tunnel)
      |> set_argv(~w(tunnel --input enabled help))
      |> cli_test()
      # Enabled collapsed
      |> set_argv(~w(t -i e h))
      |> cli_test()
      # Diabled expanded
      |> set_argv(~w(tunnel --input disabled help))
      |> cli_test()
      # Disabled collapsed
      |> set_argv(~w(t -i d h))
      |> cli_test()
    end

    test "empty mode, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_input_modifier, @empty_input_modifier)
      |> set_argv(~w(tunnel --input))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -i))
      |> cli_test()
    end

    test "invalid mode, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_input_mode, @invalid_input_mode)
      |> set_argv(~w(tunnel --input unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -i unknown))
      |> cli_test()
    end
  end

  describe "[rit t -p <path> | rit tunnel --path <path>]" do
    test "path valid, continue" do
      setup_cli_test()
      |> set_argv(~w(tunnel --path /tmp help))
      |> cli_test()
      # Inspect collapsed
      |> set_argv(~w(t -p /tmp h))
      |> cli_test()
    end

    test "empty path, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_path_modifier, @empty_path_modifier)
      |> set_argv(~w(tunnel --path))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -p))
      |> cli_test()
    end

    test "invalid path, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_path)
      |> set_argv(~w(tunnel --path /unknown/path))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(t -p /unknown/path))
      |> cli_test()
    end
  end

  describe "[rit ???]" do
    test "modifier invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_modifier, @invalid_modifier)
      |> set_argv(~w(tunnel --unknown))
      |> cli_test()
    end

    test "context invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_command, @invalid_command)
      |> set_argv(~w(tunnel unknown))
      |> cli_test()
    end
  end
end

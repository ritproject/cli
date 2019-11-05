defmodule RitCLITest.CLI.Config.TunnelTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel

  @empty_command "at least a config tunnel command must be provided"
  @invalid_command "the config tunnel command 'unknown' is invalid"

  describe "[rit c t | rit tunnel config]" do
    test "show error and config tunnel helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel))
      |> set_exit_code(1)
      |> add_error_output(:empty_command, @empty_command)
      |> add_helper_output(Tunnel)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t))
      |> cli_test()
    end
  end

  describe "[rit c t h | rit config tunnel help]" do
    test "show config tunnel helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel help))
      |> add_helper_output(Tunnel)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t h))
      |> cli_test()
    end
  end

  describe "[rit c t ??? | rit config tunnel ???]" do
    test "command invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_command, @invalid_command)
      |> set_argv(~w(config tunnel unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t unknown))
      |> cli_test()
    end
  end
end

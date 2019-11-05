defmodule RitCLITest.CLI.Config.Tunnel.ShowTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Show
  alias RitCLI.Config.TunnelStorage

  @argument_invalid_name "argument 'name' with value '42' must start and finish with a letter and must contain only letters and underscore"
  @empty_argument "a name must be provided"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit c t s | rit config tunnel show]" do
    test "show error and config tunnel show helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel show))
      |> set_exit_code(1)
      |> add_error_output(:empty_argument, @empty_argument)
      |> add_helper_output(Show)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t s))
      |> cli_test()
    end
  end

  describe "[rit c t s help | rit config tunnel show help]" do
    test "show config tunnel show helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel show help))
      |> add_helper_output(Show)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t s help))
      |> cli_test()
    end
  end

  describe "[rit config tunnel show <name>]" do
    test "invalid name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel show 42))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_name)
      |> cli_test()
    end
  end
end

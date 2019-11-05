defmodule RitCLITest.CLI.Config.Tunnel.RemoveTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Remove
  alias RitCLI.Config.TunnelStorage

  @argument_invalid_name "argument 'name' with value '42' must start and finish with a letter and must contain only letters and underscore"
  @empty_argument "a name must be provided"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit c t r | rit config tunnel remove]" do
    test "show error and config tunnel remove helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel remove))
      |> set_exit_code(1)
      |> add_error_output(:empty_argument, @empty_argument)
      |> add_helper_output(Remove)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t r))
      |> cli_test()
    end
  end

  describe "[rit c t r help | rit config tunnel remove help]" do
    test "show config tunnel remove helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel remove help))
      |> add_helper_output(Remove)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t r help))
      |> cli_test()
    end
  end

  describe "[rit config tunnel remove <name>]" do
    test "invalid name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel remove 42))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_name)
      |> cli_test()
    end
  end
end

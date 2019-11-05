defmodule RitCLITest.CLI.Config.Tunnel.DefaultTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Default

  @empty_command "at least a default config tunnel command must be provided"
  @invalid_command "the default config tunnel command 'unknown' is invalid"

  describe "[rit c t d | rit tunnel config default]" do
    test "show error and config tunnel helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default))
      |> set_exit_code(1)
      |> add_error_output(:empty_command, @empty_command)
      |> add_helper_output(Default)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d))
      |> cli_test()
    end
  end

  describe "[rit c t d h | rit config tunnel default help]" do
    test "show config tunnel default helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel default help))
      |> add_helper_output(Default)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d h))
      |> cli_test()
    end
  end

  describe "[rit c t d ??? | rit config tunnel default ???]" do
    test "command invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_command, @invalid_command)
      |> set_argv(~w(config tunnel default unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t d unknown))
      |> cli_test()
    end
  end
end

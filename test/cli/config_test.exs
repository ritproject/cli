defmodule RitCLITest.CLI.ConfigTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config

  @empty_type "at least a config type must be provided"
  @invalid_type "the config type 'unknown' is invalid"

  describe "[rit c | rit config]" do
    test "show error and config helper" do
      setup_cli_test()
      |> set_argv(~w(config))
      |> set_exit_code(1)
      |> add_error_output(:empty_type, @empty_type)
      |> add_helper_output(Config)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c))
      |> cli_test()
    end
  end

  describe "[rit c h | rit config help]" do
    test "show config helper" do
      setup_cli_test()
      |> set_argv(~w(config help))
      |> add_helper_output(Config)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c h))
      |> cli_test()
    end
  end

  describe "[rit c ??? | rit config ???]" do
    test "type invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_type, @invalid_type)
      |> set_argv(~w(config unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c unknown))
      |> cli_test()
    end
  end
end

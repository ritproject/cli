defmodule RitCLITest.CLI.Config.Tunnel.AddTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.Config.Tunnel.Add
  alias RitCLI.Config.TunnelStorage

  @link "http://#{String.duplicate("a", 150)}.com/unknown"

  @argument_invalid_local_reference "argument 'reference' with value '/unknown' must be a valid path"
  @argument_invalid_repo_reference "argument 'reference' with value '#{@link}' must have at most 150 characters"
  @argument_invalid_name "argument 'name' with value 'x' must have at least 2 and at most 20 characters"
  @argument_invalid_from "argument 'from' with value 'unknown' must be 'local' or 'repo'"
  @empty_arguments "at least from and reference arguments must be provided"

  setup_all do
    TunnelStorage.clear_storage()
  end

  describe "[rit c t a | rit config tunnel add]" do
    test "show error and config tunnel add helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add))
      |> set_exit_code(1)
      |> add_error_output(:empty_arguments, @empty_arguments)
      |> add_helper_output(Add)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t a))
      |> cli_test()
    end
  end

  describe "[rit c t a help | rit config tunnel add help]" do
    test "show config tunnel add helper" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add help))
      |> add_helper_output(Add)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(c t a help))
      |> cli_test()
    end
  end

  describe "[rit config tunnel add <from>]" do
    test "invalid from, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add unknown))
      |> set_exit_code(1)
      |> add_error_output(:invalid_arguments, @empty_arguments)
      |> cli_test()
    end
  end

  describe "[rit config tunnel add <from> <reference>]" do
    test "invalid from, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add unknown /tmp))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_from)
      |> cli_test()
    end
  end

  describe "[rit config tunnel add local <reference>]" do
    test "invalid reference, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /unknown))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_local_reference)
      |> cli_test()
    end
  end

  describe "[rit config tunnel add repo <reference>]" do
    test "invalid reference, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add repo #{@link}))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_repo_reference)
      |> cli_test()
    end
  end

  describe "[rit config tunnel add local <reference> --name <name>]" do
    test "invalid name, show error" do
      setup_cli_test()
      |> set_argv(~w(config tunnel add local /tmp --name x))
      |> set_exit_code(1)
      |> add_error_output(:argument_invalid, @argument_invalid_name)
      |> cli_test()
    end
  end
end

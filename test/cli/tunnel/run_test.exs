defmodule RitCLITest.CLI.Tunnel.RunTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Tunnel.Run
  alias RitCLITest.TunnelSettings

  @command_failed "command 'cat' with arguments 'unknown.txt' failed with code '1'"
  @command_failed_map %{
    data: "\n/bin/cat: unknown.txt: No such file or directory\n",
    error: %{
      exit_code: 1,
      id: :command_failed,
      message: @command_failed,
      message_raw:
        "command '%{command}' with arguments '%{arguments}' failed with code '%{code}'",
      metadata: %{
        arguments: "unknown.txt",
        code: 1,
        command: "cat"
      },
      where: Run
    }
  }

  @invalid_input_settings "input setting default not found"
  @invalid_settings "run key on referenced settings does not exists"
  @link_failed "OS failed to link target path with source"
  @settings_not_found "referenced settings file on source directory does not exists"
  @undefined_link_dir "link_dir must be set if link_mode is not 'none'"
  @unknown_operation "operation to perform not found on settings file"

  setup_all do
    TunnelStorage.clear_storage()
    TunnelSettings.reset()

    operation = fn ->
      RitCLI.main(~w(config tunnel add local /test))
      RitCLI.main(~w(config tunnel default set test))
    end

    capture_io(operation)

    on_exit(fn ->
      TunnelStorage.clear_storage()
      TunnelSettings.clear()
    end)
  end

  setup do
    on_exit(fn -> TunnelSettings.reset() end)
  end

  describe "(successful) [rit tunnel run ???]" do
    test ":run" do
      TunnelSettings.set(:run)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_output("hello world")
      |> cli_test()
    end

    test ":redirect_internal" do
      TunnelSettings.set(:redirect_internal)

      setup_cli_test()
      |> set_argv(~w(tunnel run hello redirect))
      |> add_output("hello\nworld")
      |> cli_test()
    end

    test ":redirect_external" do
      TunnelSettings.set(:redirect_external)

      setup_cli_test()
      |> set_argv(~w(tunnel run hello redirect))
      |> add_output("hello\nworld")
      |> cli_test()
    end

    test ":redirect_external_internal" do
      TunnelSettings.set(:redirect_external_internal)

      setup_cli_test()
      |> set_argv(~w(tunnel run hello redirect))
      |> add_output("hello\nworld")
      |> cli_test()
    end

    test ":redirect_strict" do
      TunnelSettings.set(:redirect_strict)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_output("hello world")
      |> cli_test()
    end

    test ":input" do
      TunnelSettings.set(:input)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_input("hello world")
      |> add_output("hello world")
      |> cli_test()
    end

    test ":input_with_default" do
      TunnelSettings.set(:input_with_default)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_input("")
      |> add_output("hello world")
      |> cli_test()
    end

    test ":input_with_default and input disabled" do
      TunnelSettings.set(:input_with_default)

      setup_cli_test()
      |> set_argv(~w(tunnel --input disabled run))
      |> add_output("hello world")
      |> cli_test()
    end

    test ":link_mode_symlink" do
      TunnelSettings.set(:link_mode_symlink)

      setup_cli_test()
      |> set_argv(~w(tunnel --path /test_target run))
      |> add_output("hello world")
      |> cli_test()
    end

    test ":link_mode_copy" do
      TunnelSettings.set(:link_mode_copy)

      setup_cli_test()
      |> set_argv(~w(tunnel --path /test_target run))
      |> add_output("hello world")
      |> cli_test()
    end
  end

  describe "(failed) [rit tunnel run ???]" do
    test ":redirect_external_no_child" do
      TunnelSettings.set(:redirect_external_no_child)

      setup_cli_test()
      |> set_argv(~w(tunnel run hello redirect))
      |> add_error_output(:settings_not_found, @settings_not_found)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":input without default and empty input" do
      TunnelSettings.set(:input)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_input("")
      |> add_error_output(:invalid_input_settings, @invalid_input_settings)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":input without default and input disabled" do
      TunnelSettings.set(:input)

      setup_cli_test()
      |> set_argv(~w(tunnel --input disabled run))
      |> add_error_output(:invalid_input_settings, @invalid_input_settings)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":link_mode_without_link_dir" do
      TunnelSettings.set(:link_mode_without_link_dir)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_error_output(:undefined_link_dir, @undefined_link_dir)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":link_dir_invalid" do
      TunnelSettings.set(:link_dir_invalid)

      setup_cli_test()
      |> set_argv(~w(tunnel --path /test_target run))
      |> add_error_output(:link_failed, @link_failed)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":no_operation" do
      TunnelSettings.set(:no_operation)

      setup_cli_test()
      |> set_argv(~w(tunnel run no operation))
      |> add_error_output(:unknown_operation, @unknown_operation)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":fail_on_joined_run" do
      TunnelSettings.set(:fail_on_joined_run)

      setup_cli_test()
      |> set_argv(~w(tunnel run success fail success))
      |> add_error_output(:command_failed, @command_failed)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":fail_on_joined_run with ugly_json output mode" do
      TunnelSettings.set(:fail_on_joined_run)

      setup_cli_test()
      |> set_argv(~w(--output ugly_json tunnel run success fail success))
      |> add_output(Jason.encode!(@command_failed_map))
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":run_not_found" do
      TunnelSettings.set(:run_not_found)

      setup_cli_test()
      |> set_argv(~w(tunnel run))
      |> add_error_output(:invalid_settings, @invalid_settings)
      |> set_exit_code(1)
      |> cli_test()
    end
  end
end

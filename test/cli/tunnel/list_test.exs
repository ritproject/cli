defmodule RitCLITest.CLI.Tunnel.ListTest do
  use RitCLITest.CLIUtils

  alias RitCLI.Config.TunnelStorage
  alias RitCLITest.TunnelSettings

  @direct "(direct)"
  @run "(run)"
  @redirect_internal """
  - hello
    (run)
  - hello redirect
    (redirect)
  - world
    (run)\
  """
  @redirect_internal_filtered """
  - hello

  - hello redirect
    (redirect)\
  """
  @redirect_external """
  - hello
    (run)
  - hello redirect
    (redirect, run)\
  """
  @redirect_external_map %{
    data: %{
      "hello" => %{
        :run => true,
        "redirect" => %{
          redirect: true,
          run: true
        }
      }
    }
  }
  @redirect_external_composite """
  - hello
    (run)
  - hello redirect
    (redirect)
  - hello redirect external
    (run)\
  """
  @redirect_external_composite_filtered """
  - hello

  - hello redirect

  - hello redirect external
    (run)\
  """
  @redirect_strict_depth_one """
  - only
    (run)\
  """
  @redirect_strict_filtered """
  - only

  - only show
    (run)
  - only show hello_world
    (redirect)\
  """
  @redirect_strict_filtered_depth_one """
  - only

  - only show
    (run)
  - only show hello_world
    (redirect)\
  """
  @redirect_strict """
  (redirect)
  - only
    (run)
  - only show
    (run)
  - only show hello_world
    (redirect)
  - show
    (run)
  - show hello_world
    (run)\
  """

  @config_reference_not_found "the configuration reference on '/test' does not exists"
  @failed_to_fetch "git command reported a failure"
  @invalid_depth "depth value must be a positive number or infinity"
  @invalid_settings "run key on referenced settings does not exists"
  @no_commands "There are no commands set on setting"
  @not_found "while following arguments on setting file, the 'error' could not be found"
  @settings_invalid "referenced settings file on source directory is not a valid YAML rit settings file"
  @settings_not_found "referenced settings file on source directory does not exists"

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
    on_exit(fn ->
      TunnelStorage.clear_storage()
      TunnelSettings.reset()

      operation = fn ->
        RitCLI.main(~w(config tunnel add local /test))
        RitCLI.main(~w(config tunnel default set test))
      end

      capture_io(operation)
    end)
  end

  describe "(successful) [rit tunnel list ???]" do
    test ":run" do
      TunnelSettings.set(:run)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@run)
      |> cli_test()
    end

    test ":list" do
      TunnelSettings.set(:list)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@run)
      |> cli_test()
    end

    test ":link_dir_invalid" do
      TunnelSettings.set(:link_dir_invalid)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@direct)
      |> cli_test()
    end

    test ":redirect_internal" do
      TunnelSettings.set(:redirect_internal)

      setup_cli_test()
      |> set_argv(~w(tunnel list --depth infinity))
      |> add_output(@redirect_internal)
      |> cli_test()
    end

    test ":redirect_internal with filter" do
      TunnelSettings.set(:redirect_internal)

      setup_cli_test()
      |> set_argv(~w(tunnel list hello redirect))
      |> add_output(@redirect_internal_filtered)
      |> cli_test()
    end

    test ":redirect_external" do
      TunnelSettings.set(:redirect_external)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@redirect_external)
      |> cli_test()
    end

    test ":redirect_external with output mode inspect" do
      TunnelSettings.set(:redirect_external)

      setup_cli_test()
      |> set_argv(~w(--output inspect tunnel list))
      |> add_output(inspect(@redirect_external_map, pretty: true))
      |> cli_test()
    end

    test ":redirect_external_composite" do
      TunnelSettings.set(:redirect_external_composite)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@redirect_external_composite)
      |> cli_test()
    end

    test ":redirect_external_composite with filter" do
      TunnelSettings.set(:redirect_external_composite)

      setup_cli_test()
      |> set_argv(~w(tunnel list hello redirect))
      |> add_output(@redirect_external_composite_filtered)
      |> cli_test()
    end

    test ":redirect_strict" do
      TunnelSettings.set(:redirect_strict)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@redirect_strict)
      |> cli_test()
    end

    test ":redirect_strict with depth 1" do
      TunnelSettings.set(:redirect_strict)

      setup_cli_test()
      |> set_argv(~w(tunnel list --depth 1))
      |> add_output(@redirect_strict_depth_one)
      |> cli_test()
    end

    test ":redirect_strict with filter" do
      TunnelSettings.set(:redirect_strict)

      setup_cli_test()
      |> set_argv(~w(tunnel list only show))
      |> add_output(@redirect_strict_filtered)
      |> cli_test()
    end

    test ":redirect_strict with depth 1 and filter" do
      TunnelSettings.set(:redirect_strict)

      setup_cli_test()
      |> set_argv(~w(tunnel list --depth 1 only show))
      |> add_output(@redirect_strict_filtered_depth_one)
      |> cli_test()
    end

    test ":invalid_argument, show no commands" do
      TunnelSettings.set(:invalid_argument)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_output(@no_commands)
      |> cli_test()
    end
  end

  describe "(failed) [rit tunnel list ???]" do
    test ":redirect_external_no_child" do
      TunnelSettings.set(:redirect_external_no_child)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_error_output(:settings_not_found, @settings_not_found)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":redirect_external_no_child with filter" do
      TunnelSettings.set(:redirect_external_no_child)

      setup_cli_test()
      |> set_argv(~w(tunnel list hello redirect no_child))
      |> add_error_output(:settings_not_found, @settings_not_found)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":invalid_argument with filter" do
      TunnelSettings.set(:invalid_argument)

      setup_cli_test()
      |> set_argv(~w(tunnel list invalid error))
      |> add_error_output(:argument_not_found, @not_found)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":run_not_found" do
      TunnelSettings.set(:run_not_found)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_error_output(:invalid_settings, @invalid_settings)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":invalid_yaml" do
      TunnelSettings.set(:invalid_yaml)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_error_output(:settings_invalid, @settings_invalid)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":run with invalid depth" do
      TunnelSettings.set(:run)

      setup_cli_test()
      |> set_argv(~w(tunnel list --depth hello))
      |> add_error_output(:invalid_depth, @invalid_depth)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":run with invalid local config" do
      TunnelSettings.set(:run)
      File.rm_rf!("/test")

      setup_config = fn ->
        RitCLI.main(~w(config tunnel default set test --path /tmp))
      end

      capture_io(setup_config)

      setup_cli_test()
      |> set_argv(~w(tunnel --path /tmp list))
      |> add_error_output(:config_reference_not_found, @config_reference_not_found)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":run with invalid repo config" do
      TunnelSettings.set(:run)

      setup_config = fn ->
        ~w(
          config tunnel edit test
            --from repo
            --reference https://gitlab.com/ritproject/unknown
            --name test
        ) |> RitCLI.main()
      end

      capture_io(setup_config)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_error_output(:failed_to_fetch, @failed_to_fetch)
      |> set_exit_code(1)
      |> cli_test()
    end

    test ":run with no configuration on repo" do
      TunnelSettings.set(:run)

      setup_config = fn ->
        ~w(
          config tunnel edit test
            --from repo
            --reference https://gitlab.com/ritproject/cli
            --name test
        ) |> RitCLI.main()
      end

      capture_io(setup_config)

      setup_cli_test()
      |> set_argv(~w(tunnel list))
      |> add_error_output(:settings_not_found, @settings_not_found)
      |> set_exit_code(1)
      |> cli_test()
      |> cli_test()
    end
  end
end

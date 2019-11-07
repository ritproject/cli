defmodule RitCLITest.CLI.MainTest do
  use RitCLITest.CLIUtils, async: true

  alias RitCLI.{Git, Main}

  @empty_argument "at least a context must be provided"
  @empty_log_modifier "log mode must be provided"
  @empty_output_modifier "output mode must be provided"
  @invalid_context "the context 'unknown' is invalid"
  @invalid_log_mode "the log mode 'unknown' is invalid"
  @invalid_modifier "the modifier 'unknown' is invalid"
  @invalid_output_mode "the output mode 'unknown' is invalid"

  describe "[rit]" do
    test "show error and main helper" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_argument, @empty_argument)
      |> add_helper_output(Main)
      |> cli_test()
    end
  end

  describe "[rit h | rit help]" do
    test "show main helper" do
      setup_cli_test()
      |> set_argv(~w(help))
      |> add_helper_output(Main)
      |> cli_test()
      # Collapsed
      |> set_argv(~w(h))
      |> cli_test()
    end

    test "show main helper, parsed" do
      operation = fn ->
        assert RitCLI.parse_and_exec("help") == :ok
      end

      assert capture_io(operation) == helper_output(Main) <> "\n"
    end
  end

  describe "[rit v | rit version]" do
    test "show rit version" do
      version = Keyword.get(Mix.Project.config(), :version)
      commit = ~w(rev-parse --short HEAD) |> Git.run() |> elem(1) |> String.trim_trailing("\n")

      setup_cli_test()
      |> set_argv(~w(version))
      |> add_success_output("rit v#{version} (#{commit})")
      |> cli_test()
      # Collapsed
      |> set_argv(~w(v))
      |> cli_test()
    end

    test "show main helper, parsed" do
      operation = fn ->
        assert RitCLI.parse_and_exec("help") == :ok
      end

      assert capture_io(operation) == helper_output(Main) <> "\n"
    end
  end

  describe "[rit -l <mode> | rit --log <mode>]" do
    test "mode valid, continue" do
      setup_cli_test()
      |> add_helper_output(Main)
      |> set_argv(~w(--log batch help))
      |> cli_test()
      # Batch collapsed
      |> set_argv(~w(-l b h))
      |> cli_test()
      # On Error expanded
      |> set_argv(~w(--log on_error help))
      |> cli_test()
      # On Error collapsed
      |> set_argv(~w(-l o h))
      |> cli_test()
      # Disabled expanded
      |> set_argv(~w(--log disabled help))
      |> cli_test()
      # Disabled collapsed
      |> set_argv(~w(-l d h))
      |> cli_test()
    end

    test "empty mode, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_log_modifier, @empty_log_modifier)
      |> set_argv(~w(--log))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(-l))
      |> cli_test()
    end

    test "invalid mode, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_log_mode, @invalid_log_mode)
      |> set_argv(~w(--log unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(-l unknown))
      |> cli_test()
    end
  end

  describe "[rit -o <mode> | rit --output <mode>]" do
    test "mode valid, continue" do
      setup_cli_test()
      |> set_argv(~w(--output inspect help))
      |> cli_test()
      # Inspect collapsed
      |> set_argv(~w(-o i h))
      |> cli_test()
      # JSON expanded
      |> set_argv(~w(--output json help))
      |> cli_test()
      # JSON collapsed
      |> set_argv(~w(-o j h))
      |> cli_test()
      # Plain expanded
      |> set_argv(~w(--output plain help))
      |> cli_test()
      # Plain collapsed
      |> set_argv(~w(-o p h))
      |> cli_test()
      # JSON  Uglified expanded
      |> set_argv(~w(--output ugly_json help))
      |> cli_test()
      # JSON Uglified collapsed
      |> set_argv(~w(-o u h))
      |> cli_test()
    end

    test "empty mode, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:empty_output_modifier, @empty_output_modifier)
      |> set_argv(~w(--output))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(-o))
      |> cli_test()
    end

    test "invalid mode, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_output_mode, @invalid_output_mode)
      |> set_argv(~w(--output unknown))
      |> cli_test()
      # Collapsed
      |> set_argv(~w(-o unknown))
      |> cli_test()
    end

    test "valid mode, without context, show error" do
      setup_cli_test()
      |> set_argv(~w(--log batch))
      |> add_error_output(:empty_context, @empty_argument)
      |> set_exit_code(1)
      |> cli_test()
    end
  end

  describe "[rit ???]" do
    test "ouput and log modes, continue" do
      setup_cli_test()
      |> set_argv(~w(--output inspect --log batch help))
      |> cli_test()
    end

    test "modifier invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_modifier, @invalid_modifier)
      |> set_argv(~w(--unknown))
      |> cli_test()
    end

    test "context invalid, show error" do
      setup_cli_test()
      |> set_exit_code(1)
      |> add_error_output(:invalid_context, @invalid_context)
      |> set_argv(~w(unknown))
      |> cli_test()
    end

    test "with unknown error, show unknown message" do
      operation = fn ->
        assert catch_exit(RitCLI.main(["config", nil])) == {:shutdown, 1}
      end

      assert capture_io(operation) =~ "rit unexpectedly failed"
    end
  end
end

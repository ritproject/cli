defmodule RitCLITest.CLIUtils do
  alias RitCLI.Meta.{Helper, Output}
  alias RitCLITest.CLIUtils

  import ExUnit.Assertions
  import ExUnit.CaptureIO

  defstruct argv: [],
            input_list: [],
            output_list: [],
            exit_code: nil

  defmacro __using__(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      import ExUnit.CaptureIO
      import RitCLITest.CLIUtils
    end
  end

  def setup_cli_test, do: %CLIUtils{}

  def set_argv(utils, argv), do: struct(utils, argv: argv)

  def set_exit_code(utils, exit_code), do: struct(utils, exit_code: exit_code)

  def add_input(utils, input) do
    struct(utils, input_list: utils.input_list ++ [input])
  end

  def add_output(utils, output) do
    struct(utils, output_list: utils.output_list ++ [output])
  end

  def add_error_output(utils, id, output) do
    add_output(utils, error_output(id, output))
  end

  def add_helper_output(utils, module) do
    add_output(utils, helper_output(module))
  end

  def add_success_output(utils, output) do
    add_output(utils, success_output(output))
  end

  def cli_test(utils) do
    if utils.exit_code do
      cli_test_failure(utils)
    else
      cli_test_success(utils)
    end
  end

  def cli_test_success(utils) do
    cli_success(utils.argv, utils.output_list, utils.input_list)
    utils
  end

  def cli_test_failure(utils) do
    cli_failure(utils.argv, utils.output_list, utils.exit_code, utils.input_list)
    utils
  end

  def error_output(id, output) do
    Output.interpolate_colors(
      "[%{error}] %{focus}: %{info}",
      ["error", Recase.to_sentence("#{id}"), output]
    )
  end

  def helper_output(module) do
    Helper.to_string(module, color?: true)
  end

  def success_output(output) do
    Output.interpolate_colors(
      "[%{success}] %{info}",
      ["success", output]
    )
  end

  def cli_failure(argv, output, exit_code \\ 0, input \\ []) do
    command(argv, output, input, exit_code)
  end

  def cli_success(argv, output, input \\ []) do
    command(argv, output, input)
  end

  defp command(argv, output, input, exit_code \\ nil) do
    execution = fn ->
      if exit_code do
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, exit_code}
      else
        assert RitCLI.main(argv) == :ok
      end
    end

    if input == "" or Enum.empty?(input) do
      assert capture_io(execution) =~ join_output(output)
    else
      assert capture_io(join_input(input), execution) =~ join_output(output)
    end
  end

  defp join_input(input) do
    if is_list(input) do
      Enum.join(input, "\n")
    else
      input
    end <> "\n"
  end

  defp join_output(output) do
    if output != "" and not Enum.empty?(output) do
      if is_list(output) do
        Enum.join(output, "\n")
      else
        output
      end <> "\n"
    else
      ""
    end
  end
end

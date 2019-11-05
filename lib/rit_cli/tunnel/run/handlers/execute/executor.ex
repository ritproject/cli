defmodule RitCLI.Tunnel.Run.Handler.Execute.Executor do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.Run.{RunHandler, Runner}

  alias RitCLI.Tunnel.Run.Handler.Execute.{
    EnvironmentManager,
    InputManager,
    LinkManager
  }

  @spec execute(Meta.t(), Runner.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def execute(%Meta{} = meta, %Runner{} = runner) do
    case LinkManager.link(meta, runner) do
      {:ok, meta, runner} -> get_input_and_execute(meta, runner)
      error -> error
    end
  end

  @spec execute_and_continue(Meta.t(), Runner.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def execute_and_continue(%Meta{} = meta, %Runner{} = runner) do
    case execute(meta, runner) do
      {:ok, meta} -> continue_or_finish(meta, runner)
      error -> error
    end
  end

  defp continue_or_finish(meta, %{operation_cache: cache} = runner) do
    if cache do
      runner =
        struct(
          runner,
          operation: nil,
          operation_mode: nil,
          operation_cache: nil,
          prefixes: cache.prefixes
        )

      RunHandler.handle(meta, runner, cache.settings, cache.args)
    else
      {:ok, meta}
    end
  end

  defp get_input_and_execute(meta, runner) do
    case InputManager.prompt(meta, runner) do
      {:ok, meta, runner} -> execute_operation(meta, runner)
      error -> error
    end
  end

  defp execute_operation(meta, runner) do
    case runner.operation do
      operation when is_binary(operation) -> execute_one(meta, runner, operation)
      operations when is_list(operations) -> execute_many(meta, runner, operations)
    end
  end

  defp execute_one(meta, runner, operation) do
    [command | arguments] =
      operation
      |> EnvironmentManager.interpolate(runner.environment)
      |> String.split(" ", trim: true)

    execute_command(meta, runner, command, arguments)
  end

  defp execute_many(meta, runner, operations) do
    Enum.reduce_while(operations, {:ok, meta}, fn operation, _result ->
      case execute_one(meta, runner, operation) do
        {:ok, _meta} = result -> {:cont, result}
        {:error, _meta} = error -> {:halt, error}
      end
    end)
  end

  defp execute_command(meta, runner, command, arguments) do
    log_execution_started(meta, command, arguments)

    if meta.main.output_mode == :plain do
      execute_command_and_show_in_real_time!(meta, runner, command, arguments)
    else
      execute_command_and_save_result!(meta, runner, command, arguments)
    end
  rescue
    error -> {:error, operation_os_failure_error(meta, error)}
  end

  defp execute_command_and_show_in_real_time!(meta, runner, command, arguments) do
    {_stream, code} =
      File.cd!(
        runner.source_path,
        fn ->
          System.cmd(
            command,
            arguments,
            env: EnvironmentManager.build_list_of_tuples(runner.environment),
            into: IO.stream(:stdio, :line),
            stderr_to_stdout: true
          )
        end
      )

    log_execution_finished(meta, command, arguments, code)
  end

  defp execute_command_and_save_result!(meta, runner, command, arguments) do
    {output, code} =
      File.cd!(
        runner.source_path,
        fn ->
          System.cmd(
            command,
            arguments,
            env: EnvironmentManager.build_list_of_tuples(runner.environment),
            stderr_to_stdout: true
          )
        end
      )

    meta =
      if meta.output.data do
        Meta.set_output_data(meta, meta.output.data <> "\n" <> output)
      else
        Meta.set_output_data(meta, output)
      end

    log_execution_finished(meta, command, arguments, code)
  end

  defp log_execution_finished(meta, command, arguments, code) do
    if code == 0 do
      {:ok, log_execution_success(meta, command, arguments)}
    else
      {:error, operation_failure_error(meta, command, arguments, code)}
    end
  end

  defp log_execution_started(meta, command, arguments) do
    Meta.log(
      meta,
      :info,
      "tunnel will run command '%{command}' with arguments '%{arguments}'",
      command: command,
      arguments: Enum.join(arguments, " ")
    )
  end

  defp log_execution_success(meta, command, arguments) do
    Meta.log(
      meta,
      :success,
      "executed '%{command}' with arguments '%{arguments}'",
      command: command,
      arguments: Enum.join(arguments, " ")
    )
  end

  defp operation_failure_error(meta, command, arguments, code) do
    Meta.error(
      meta,
      :command_failed,
      "command '%{command}' with arguments '%{arguments}' failed with code '%{code}'",
      [command: command, arguments: Enum.join(arguments, " "), code: code],
      code
    )
  end

  defp operation_os_failure_error(meta, error) do
    Meta.error(
      meta,
      :command_failed,
      "OS failed to access source directory",
      error: inspect(error)
    )
  end
end

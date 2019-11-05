defmodule RitCLI.Tunnel.Run.Handler.Execute.InputManager do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Meta.Error
  alias RitCLI.Meta.Output
  alias RitCLI.Tunnel.Run.Runner

  @spec prompt(Meta.t(), Runner.t()) :: {:ok, Meta.t(), Runner.t()} | {:error, Meta.t()}
  def prompt(%Meta{} = meta, %Runner{} = runner) do
    cond do
      Enum.empty?(runner.input) -> {:ok, meta, runner}
      runner.input_mode == :enabled -> do_prompt(meta, runner)
      true -> use_defaults(meta, runner)
    end
  end

  defp do_prompt(meta, runner) do
    case Enum.reduce_while(runner.input, {:ok, runner.environment}, &prompt_input/2) do
      {:ok, environment} -> {:ok, meta, struct(runner, environment: environment)}
      {:error, error} -> {:error, prompt_failure_error(meta, error)}
    end
  end

  defp prompt_input({name, input}, {:ok, environment}) do
    input
    |> get_input_question(name)
    |> Output.show_plain()

    case ask() do
      "" -> use_default({name, input}, {:ok, environment})
      value -> {:cont, {:ok, Map.put(environment, get_environment_name(input, name), value)}}
    end
  end

  defp get_input_question(input, name) do
    name = Map.get(input, "name") || get_environment_name(input, name)
    message = "Please inform the value of " <> Output.colorize_focus(name)

    case Map.get(input, "defaults_to") do
      nil -> message
      default -> "#{message} (defaults to: #{default})"
    end
  end

  defp ask do
    "> "
    |> Output.colorize_success()
    |> IO.gets()
    |> String.trim()
    |> String.replace(~r/\r|\n|\t/, "")
  end

  defp use_defaults(meta, runner) do
    case Enum.reduce_while(runner.input, {:ok, runner.environment}, &use_default/2) do
      {:ok, environment} -> {:ok, meta, struct(runner, environment: environment)}
      {:error, error} -> {:error, use_default_failure_error(meta, error)}
    end
  end

  defp use_default({name, input}, {:ok, environment}) do
    case get_default_value(input) do
      {:ok, value} ->
        {:cont, {:ok, Map.put(environment, get_environment_name(input, name), value)}}

      error ->
        {:halt, error}
    end
  end

  defp get_environment_name(input, name), do: Map.get(input, "environment_name") || name

  defp get_default_value(input) do
    case Map.get(input, "defaults_to") do
      nil -> {:error, input_without_default_error()}
      value -> {:ok, value}
    end
  end

  defp input_without_default_error do
    Error.build(
      __MODULE__,
      :invalid_input_settings,
      "input setting default not found"
    )
  end

  defp prompt_failure_error(meta, error), do: Meta.error(meta, error)
  defp use_default_failure_error(meta, error), do: Meta.error(meta, error)
end

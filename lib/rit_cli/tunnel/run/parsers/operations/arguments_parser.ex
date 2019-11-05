defmodule RitCLI.Tunnel.Run.Operations.ArgumentsParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.{RunHandler, Runner}

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{settings: settings} = runner) do
    if is_map(settings) do
      parse_args(runner, settings)
    else
      runner
    end
  end

  defp parse_args(runner, settings) do
    case runner.args do
      [arg | args] -> parse_arg(runner, settings, args, arg)
      _args -> runner
    end
  end

  defp parse_arg(runner, settings, args, arg) do
    case Map.get(settings, ".#{arg}") do
      nil -> runner
      settings -> update_operation(runner, settings, args, arg)
    end
  end

  defp update_operation(runner, settings, args, arg) do
    prefixes = runner.prefixes ++ [arg]

    case runner.operation_mode do
      :execute_and_continue -> update_operation_cache(runner, settings, prefixes, args)
      _mode -> RunHandler.update_runner(struct(runner, prefixes: prefixes), settings, args)
    end
  end

  defp update_operation_cache(runner, settings, prefixes, args) do
    struct(
      runner,
      operation_cache: %{prefixes: prefixes, settings: settings, args: args}
    )
  end
end

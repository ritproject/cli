defmodule RitCLI.Tunnel.Run.OperationsParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Operations.{
    ArgumentsParser,
    DirectParser,
    ListOrStringParser,
    RedirectParser,
    RunParser
  }

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(runner) do
    runner
    |> maybe_parse(&ListOrStringParser.parse/1)
    |> maybe_parse(&RunParser.parse/1)
    |> ArgumentsParser.parse()
    |> maybe_parse(&DirectParser.parse/1)
    |> maybe_parse(&RedirectParser.parse/1)
  end

  defp maybe_parse(runner, parse_function) do
    if runner.operation_mode do
      runner
    else
      parse_function.(runner)
    end
  end
end

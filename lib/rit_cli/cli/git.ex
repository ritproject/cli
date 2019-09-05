defmodule RitCLI.CLI.Git do
  @moduledoc false

  alias RitCLI.CLI.{Input, Output}

  @spec handle_input(Input.t()) :: {:ok, Output.t()}
  def handle_input(%Input{argv: argv}) do
    case run(argv) do
      {:ok, result, 0} -> {:ok, %Output{module_id: :git, message: result}}
      {:ok, result, code} -> {:ok, %Output{module_id: :git, error: result, code: code}}
    end
  end

  @spec run(list(String.t())) :: {:ok, Strint.t(), integer}
  def run(argv) do
    {result, code} = System.cmd("git", argv, stderr_to_stdout: true)
    {:ok, result, code}
  end
end

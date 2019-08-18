defmodule RitCLI.Git do
  @moduledoc """
  RitCLI.Git allow to use Git normally with `&RitCLI.Git.run/1`
  and handle the git input from Rit execution with `&RitCLI.Git.handle_input/1`.
  """

  alias RitCLI.CLI.{Input, Output}

  @spec handle_input(Input.t()) :: {:ok, Output.t()}
  def handle_input(%Input{argv: argv}) do
    case run(argv) do
      {:ok, result, 0} -> {:ok, %Output{module_id: :git, message: result}}
      {:ok, result, code} -> {:ok, %Output{module_id: :git, error: result, code: code}}
    end
  end

  @spec run([binary()]) :: {:ok, binary(), integer()}
  def run(argv) do
    {result, code} = System.cmd("git", argv)
    {:ok, result, code}
  end
end

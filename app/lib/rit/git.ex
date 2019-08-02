defmodule Rit.Git do
  @moduledoc """
  Rit.Git allow to use Git normally with `&Rit.Git.run/1`
  and handle the git input from Rit execution with `&Rit.Git.handle_input/1`.
  """

  alias Rit.CLI.{Input, Output}

  def handle_input(%Input{argv: argv}) do
    case run(argv) do
      {:ok, result, code} ->
        Output.inform(result)
        code

      error ->
        error
    end
  end

  def run(argv) do
    {result, code} = System.cmd("git", argv)
    {:ok, result, code}
  rescue
    _error -> {:error, :git_failed_to_run, argv}
  end
end

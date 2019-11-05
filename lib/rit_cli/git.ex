defmodule RitCLI.Git do
  @moduledoc false

  @spec run(list(String.t())) :: {:ok, String.t(), integer}
  def run(argv) do
    {result, code} = System.cmd("git", argv, stderr_to_stdout: true)
    {:ok, result, code}
  end
end

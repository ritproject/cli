defmodule RitCLI do
  @moduledoc """
  Rit CLI improves the Git CLI, including:

  - All the Git commands
  """

  alias RitCLI.CLI
  alias RitCLI.CLI.Output

  @spec main([binary()]) :: :ok | none()
  def main(argv) do
    handle_result(CLI.handle_input(argv))
  end

  defp handle_result(result) do
    case result do
      {:ok, %Output{} = output} -> inform_and_maybe_exit(output)
      {:error, _type, %Output{} = output} -> inform_and_maybe_exit(output)
    end
  end

  defp inform_and_maybe_exit(%Output{} = output) do
    %Output{code: code} = Output.inform(output)

    if code == 0 do
      :ok
    else
      exit({:shutdown, code})
    end
  end
end

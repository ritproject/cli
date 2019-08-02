defmodule Rit do
  @moduledoc """
  Rit CLI improves the Git CLI, including:

  - All the Git commands
  """

  alias Rit.CLI
  alias Rit.CLI.Output

  def main(argv \\ []) do
    exit({:shutdown, CLI.handle_input(argv) |> handle_result()})
  end

  defp handle_result(:ok) do
    0
  end

  defp handle_result(code) when is_integer(code) do
    code
  end

  defp handle_result(error) do
    Output.inform(error)
    1
  end
end

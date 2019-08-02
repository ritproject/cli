defmodule Rit.CLI.Helper do
  @moduledoc false

  alias Rit.CLI.{Input, Output}

  @message """
  usage: rit <context> [arguments]

  Available contexts:
    g, git    Use your local Git CLI application
  """

  def handle_input(%Input{context: context}) do
    Output.inform(@message)
    if context == :help, do: 0, else: 1
  end
end

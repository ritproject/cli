defmodule RitCLI.CLI.Config.Tunnel.Default do
  @moduledoc false

  alias RitCLI.CLI.{Input, Output}

  alias RitCLI.CLI.Config.Tunnel.Default

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{} = input) do
    Default.Input.handle_input(input)
  end
end
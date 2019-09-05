defmodule RitCLI.CLI.Config.Server.Default.Operations do
  @moduledoc false

  alias RitCLI.CLI.Config.Server
  alias RitCLI.CLI.Config.Server.Default.Input
  alias RitCLI.CLI.Config.Server.Default.Operations

  @spec set_default_server(Input.Set.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom, Output.t()}
  def set_default_server(%Input.Set{} = input, config) do
    Operations.Set.set_default_server(input, config)
  end

  @spec unset_default_server(Input.Unset.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom, Output.t()}
  def unset_default_server(%Input.Unset{} = input, config) do
    Operations.Unset.unset_default_server(input, config)
  end
end

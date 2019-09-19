defmodule RitCLI.CLI.Tunnel.Run do
  @moduledoc false

  alias RitCLI.CLI.{Input, Output}
  alias RitCLI.CLI.Tunnel.Manager

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: operation}) do
    with {:ok, source_path} <- Manager.fetch_source(),
         {:ok, settings} <- Manager.extract_settings(source_path),
         :ok <- Manager.run(settings, operation, source_path) do
      {:ok, %Output{message: [s: "Tunnelling successfully performed"]}}
    end
  end
end

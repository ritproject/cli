defmodule RitCLI.CLI do
  @moduledoc false

  alias RitCLI.CLI.{Config, Git, Helper, Input, Output, Tunnel}

  @spec handle_input(list(String.t())) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(argv) do
    case Input.create_input_data(argv) do
      {:ok, %Input{} = input} -> redirect_to_context(input)
      error -> error
    end
  end

  defp redirect_to_context(%Input{context: context} = input) do
    input = struct(input, module_id: context)

    case context do
      :config -> Config.handle_input(input)
      :git -> Git.handle_input(input)
      :help -> Helper.handle_input(input)
      :tunnel -> Tunnel.handle_input(input)
    end
  end
end

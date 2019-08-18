defmodule RitCLI.CLI do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.Git

  @spec handle_input([binary()]) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(argv) do
    case Input.create_input_data(argv) do
      {:ok, %Input{} = input} -> redirect_to_context(input)
      error -> error
    end
  end

  defp redirect_to_context(%Input{context: context} = input) do
    case context do
      :config -> Config.handle_input(struct(input, module_id: :config))
      :git -> Git.handle_input(struct(input, module_id: :git))
      :help -> Helper.handle_input(struct(input, module_id: :help))
    end
  end
end

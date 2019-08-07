defmodule Rit.CLI do
  @moduledoc false

  alias Rit.CLI.{Config, Helper, Input}
  alias Rit.Git

  def handle_input(argv \\ []) do
    case Input.create_input_data(argv) do
      {:ok, %Input{} = input} -> redirect_to_context input
      error -> error
    end
  end

  defp redirect_to_context(%Input{context: context} = input) do
    case context do
      :config -> Config.handle_input input
      :git -> Git.handle_input input
      _ -> Helper.handle_input input
    end
  end
end

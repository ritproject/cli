defmodule RitCLI do
  @moduledoc false

  alias RitCLI.{Main, Meta}

  @spec main(list(Strict.t())) :: :ok | none
  def main(argv) do
    case Main.handle_arguments(Meta.create(argv)) do
      :ok -> :ok
      {:error, exit_code} -> exit({:shutdown, exit_code})
    end
  end

  @spec parse_and_exec(String.t()) :: :ok | none
  def parse_and_exec(input) do
    input
    |> String.split(" ")
    |> main()
  end
end

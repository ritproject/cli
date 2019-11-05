defmodule RitCLI.Tunnel do
  @moduledoc false

  alias RitCLI.{Meta, Tunnel}
  alias RitCLI.Tunnel.ArgumentsHandler

  @type t :: %Tunnel{
          config: map | nil,
          input_mode: atom,
          path: String.t() | nil
        }

  defstruct config: nil,
            input_mode: :enabled,
            path: nil

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(meta) do
    %Meta{meta | tunnel: %Tunnel{}}
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "tunnel context selected")
    |> ArgumentsHandler.handle_arguments()
  end
end

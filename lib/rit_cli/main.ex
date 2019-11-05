defmodule RitCLI.Main do
  @moduledoc false

  alias RitCLI.{Main, Meta}
  alias RitCLI.Main.ArgumentsHandler

  @type t :: %Main{
          log_mode: atom,
          output_mode: atom
        }

  defstruct context: nil,
            log_mode: :disabled,
            output_mode: :plain

  @spec handle_arguments(Meta.t()) :: :ok | {:error, integer}
  def handle_arguments(meta) do
    meta = Meta.module(meta, __MODULE__)

    try do
      case ArgumentsHandler.handle_arguments(meta) do
        {:ok, meta} -> handle_success(meta)
        {:error, meta} -> handle_error(meta)
      end
    rescue
      error -> handle_error(meta, error)
    end
  end

  defp handle_success(meta) do
    Meta.show(meta)
    :ok
  end

  defp handle_error(meta) do
    Meta.show(meta)
    {:error, meta.error.exit_code}
  end

  defp handle_error(meta, error) do
    meta =
      meta
      |> Meta.error(:unknown, "rit unexpectedly failed", error: inspect(error))
      |> Meta.main(log_mode: :on_error)
      |> Meta.show()

    {:error, meta.error.exit_code}
  end
end

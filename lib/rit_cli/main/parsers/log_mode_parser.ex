defmodule RitCLI.Main.LogModeParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type mode :: :batch | :disabled | :on_error

  @valid_modes %{
    "b" => :batch,
    "batch" => :batch,
    "d" => :disabled,
    "disabled" => :disabled,
    "o" => :on_error,
    "on_error" => :on_error
  }

  @spec parse(String.t()) :: {:ok, mode} | {:error, Error.t()}
  def parse(value) do
    mode = Map.get(@valid_modes, Recase.to_snake(value))

    if mode != nil do
      {:ok, mode}
    else
      {:error, invalid_mode_error(value)}
    end
  end

  defp invalid_mode_error(invalid_mode) do
    Error.build(
      __MODULE__,
      :invalid_log_mode,
      "the log mode '%{mode}' is invalid",
      mode: invalid_mode
    )
  end
end

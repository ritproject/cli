defmodule RitCLI.Tunnel.InputParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type mode :: :disabled | :enabled

  @valid_modes %{
    "d" => :disabled,
    "disabled" => :disabled,
    "e" => :enabled,
    "enabled" => :enabled
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
      :invalid_input_mode,
      "the input mode '%{mode}' is invalid",
      mode: invalid_mode
    )
  end
end

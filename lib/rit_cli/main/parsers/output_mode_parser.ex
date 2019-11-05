defmodule RitCLI.Main.OutputModeParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type mode :: :inspect | :json | :json_ugly | :plain

  @valid_modes %{
    "i" => :inspect,
    "inspect" => :inspect,
    "j" => :json,
    "json" => :json,
    "p" => :plain,
    "plain" => :plain,
    "u" => :json_ugly,
    "ugly_json" => :json_ugly
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
      :invalid_output_mode,
      "the output mode '%{mode}' is invalid",
      mode: invalid_mode
    )
  end
end

defmodule RitCLI.Meta.ArgumentsParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @spec parse_modifier(String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def parse_modifier(value) do
    case value do
      "--" <> modifier -> {:ok, modifier}
      "-" <> modifier -> {:ok, modifier}
      _input -> {:error, not_modifier_error(value)}
    end
  end

  defp not_modifier_error(not_modifier) do
    Error.build(
      __MODULE__,
      :not_modifier,
      "'%{modifier}' must start with - or --",
      modifier: not_modifier
    )
  end
end

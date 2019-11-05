defmodule RitCLI.Tunnel.ModifierParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type modifier :: :config | :input | :path

  @valid_modifiers %{
    "c" => :config,
    "config" => :config,
    "p" => :path,
    "path" => :path,
    "i" => :input,
    "input" => :input
  }

  @spec parse(String.t()) :: {:ok, modifier} | {:error, Error.t()}
  def parse(value) do
    modifier = Map.get(@valid_modifiers, Recase.to_snake(value))

    if modifier != nil do
      {:ok, modifier}
    else
      {:error, invalid_modifier_error(value)}
    end
  end

  defp invalid_modifier_error(invalid_modifier) do
    Error.build(
      __MODULE__,
      :invalid_modifier,
      "the modifier '%{modifier}' is invalid",
      modifier: invalid_modifier
    )
  end
end

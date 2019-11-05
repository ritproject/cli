defmodule RitCLI.Config.TypeParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type type :: :help | :tunnel

  @valid_types %{
    "h" => :help,
    "help" => :help,
    "t" => :tunnel,
    "tunnel" => :tunnel,
    "tunnels" => :tunnel
  }

  @spec parse(String.t()) :: {:ok, type} | {:error, Error.t()}
  def parse(value) do
    type = Map.get(@valid_types, Recase.to_snake(value))

    if type != nil do
      {:ok, type}
    else
      {:error, invalid_type_error(value)}
    end
  end

  defp invalid_type_error(invalid_type) do
    Error.build(
      __MODULE__,
      :invalid_type,
      "the config type '%{type}' is invalid",
      type: invalid_type
    )
  end
end

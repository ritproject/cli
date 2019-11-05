defmodule RitCLI.Config.TunnelStorage.Getter do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta.Error

  @spec has_config?(TunnelStorage.t(), String.t()) :: boolean
  def has_config?(%TunnelStorage{} = storage, name) do
    Map.has_key?(storage.configs, String.to_atom(name))
  end

  @spec get_config(TunnelStorage.t(), String.t()) :: {:ok, map} | {:error, Error.t()}
  def get_config(%TunnelStorage{} = storage, name) do
    case Map.get(storage.configs, String.to_atom(name)) do
      nil -> {:error, unknown_config_error(name)}
      config -> {:ok, config}
    end
  end

  defp unknown_config_error(name) do
    Error.build(
      __MODULE__,
      :tunnel_config_not_found,
      "tunnel config with name '%{name}' does not exists",
      name: name
    )
  end
end

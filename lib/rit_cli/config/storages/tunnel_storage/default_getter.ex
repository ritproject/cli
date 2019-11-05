defmodule RitCLI.Config.TunnelStorage.DefaultGetter do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta.Error

  # @spec has_default_config?(TunnelStorage.t(), String.t()) :: boolean
  # def has_default_config?(%TunnelStorage{} = storage, path) do
  #   Map.has_key?(storage.defaults, String.to_atom(path))
  # end

  # @spec has_global_default_config?(TunnelStorage.t()) :: boolean
  # def has_global_default_config?(%TunnelStorage{} = storage) do
  #   Map.has_key?(storage.defaults, :*)
  # end

  @spec get_default_config(TunnelStorage.t(), String.t()) :: {:ok, map} | {:error, Error.t()}
  def get_default_config(%TunnelStorage{} = storage, path) do
    case Map.get(storage.defaults, String.to_atom(path)) do
      nil -> {:error, unknown_default_config_error(path)}
      name -> TunnelStorage.get_config(storage, name)
    end
  end

  @spec get_global_default_config(TunnelStorage.t()) :: {:ok, map} | {:error, Error.t()}
  def get_global_default_config(%TunnelStorage{} = storage) do
    case Map.get(storage.defaults, :*) do
      nil -> {:error, unknown_global_default_config_error()}
      name -> TunnelStorage.get_config(storage, name)
    end
  end

  defp unknown_default_config_error(path) do
    Error.build(
      __MODULE__,
      :tunnel_default_config_not_found,
      "default tunnel config does not exists on path '%{path}'",
      path: path
    )
  end

  defp unknown_global_default_config_error do
    Error.build(
      __MODULE__,
      :tunnel_default_config_not_found,
      "tunnel global default config does not exists"
    )
  end
end

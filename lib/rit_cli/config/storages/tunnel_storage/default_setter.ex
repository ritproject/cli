defmodule RitCLI.Config.TunnelStorage.DefaultSetter do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta.Error

  @spec set_default_config(TunnelStorage.t(), String.t(), String.t()) ::
          {:ok, TunnelStorage.t()} | {:error, Error.t()}
  def set_default_config(%TunnelStorage{} = storage, name, path) do
    if TunnelStorage.has_config?(storage, name) do
      defaults =
        if path != "*" do
          Map.put(storage.defaults, String.to_atom(path), name)
        else
          Map.put(storage.defaults, :*, name)
        end

      {:ok, struct(storage, defaults: defaults)}
    else
      {:error, unknown_config_error(name)}
    end
  end

  @spec unset_default_config(TunnelStorage.t(), String.t()) ::
          {:ok, TunnelStorage.t()} | {:error, Error.t()}
  def unset_default_config(%TunnelStorage{defaults: defaults} = storage, path) do
    path = String.to_atom(path)

    if Map.has_key?(defaults, path) do
      {:ok, struct(storage, defaults: Map.drop(defaults, [path]))}
    else
      if path != :* do
        {:error, unknown_default_error(path)}
      else
        {:error, unknown_global_default_error()}
      end
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

  defp unknown_default_error(path) do
    Error.build(
      __MODULE__,
      :tunnel_default_config_not_found,
      "tunnel default config on path '%{path}' does not exists",
      path: path
    )
  end

  defp unknown_global_default_error do
    Error.build(
      __MODULE__,
      :tunnel_default_config_not_found,
      "tunnel global default config does not exists"
    )
  end
end

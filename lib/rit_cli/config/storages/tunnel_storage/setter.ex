defmodule RitCLI.Config.TunnelStorage.Setter do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta.Error

  @spec add_config(TunnelStorage.t(), String.t(), String.t(), String.t()) ::
          {:ok, TunnelStorage.t()} | {:error, Error.t()}
  def add_config(%TunnelStorage{} = storage, from, name, reference) do
    if TunnelStorage.has_config?(storage, name) do
      {:error, non_unique_error(name)}
    else
      configs =
        storage.configs
        |> Map.put(String.to_atom(name), %{from: from, reference: reference})

      {:ok, struct(storage, configs: configs)}
    end
  end

  @spec edit_config(TunnelStorage.t(), String.t(), String.t(), String.t(), String.t()) ::
          {:ok, TunnelStorage.t()} | {:error, Error.t()}
  def edit_config(%TunnelStorage{} = storage, current_name, from, name, reference) do
    if TunnelStorage.has_config?(storage, current_name) do
      {:ok, do_edit_config(storage, current_name, from, name, reference)}
    else
      {:error, unknown_config_error(current_name)}
    end
  end

  @spec remove_config(TunnelStorage.t(), String.t()) ::
          {:ok, TunnelStorage.t()} | {:error, Error.t()}
  def remove_config(%TunnelStorage{} = storage, name) do
    if TunnelStorage.has_config?(storage, name) do
      {:ok, do_remove_config(storage, name)}
    else
      {:error, unknown_config_error(name)}
    end
  end

  defp do_edit_config(storage, current_name, from, name, reference) do
    {config, configs} = Map.pop(storage.configs, String.to_atom(current_name))
    config = update_config(config, from, reference)

    {key, update_defaults?} = relate_names(current_name, name)

    storage =
      if update_defaults? do
        fetch_defaults(storage, current_name, name)
      else
        storage
      end

    struct(storage, configs: Map.put(configs, String.to_atom(key), config))
  end

  defp update_config(config, from, reference) do
    config
    |> maybe_update_from(from)
    |> maybe_update_reference(reference)
  end

  defp maybe_update_from(config, ""), do: config
  defp maybe_update_from(config, from), do: Map.put(config, :from, from)

  defp maybe_update_reference(config, ""), do: config
  defp maybe_update_reference(config, reference), do: Map.put(config, :reference, reference)

  defp relate_names(current_name, name) do
    if name != "" and name != current_name do
      {name, true}
    else
      {current_name, false}
    end
  end

  defp fetch_defaults(storage, current_name, name) do
    defaults =
      Enum.reduce(storage.defaults, %{}, fn {path, config_name}, defaults ->
        if config_name == current_name do
          Map.put(defaults, path, name)
        else
          Map.put(defaults, path, config_name)
        end
      end)

    struct(storage, defaults: defaults)
  end

  defp do_remove_config(storage, name) do
    configs = Map.drop(storage.configs, [String.to_atom(name)])

    defaults =
      Enum.reduce(storage.defaults, %{}, fn {path, config_name}, defaults ->
        if name == config_name do
          defaults
        else
          Map.put(defaults, path, config_name)
        end
      end)

    struct(storage, configs: configs, defaults: defaults)
  end

  defp non_unique_error(name) do
    Error.build(
      __MODULE__,
      :non_unique_tunnel_config,
      "tunnel config with name '%{name}' already exists",
      name: name
    )
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

defmodule RitCLI.Config.TunnelStorage do
  @moduledoc false

  alias RitCLI.Meta.Error
  alias RitCLI.Config.{StorageManager, TunnelStorage}
  alias RitCLI.Config.TunnelStorage.{DefaultGetter, DefaultSetter, Getter, Setter}

  @type t :: %TunnelStorage{
          configs: map,
          defaults: map
        }

  @derive Jason.Encoder
  defstruct configs: %{},
            defaults: %{}

  @context "tunnel"

  @spec get_storage :: TunnelStorage.t()
  def get_storage do
    struct!(TunnelStorage, StorageManager.get_storage(@context))
  rescue
    _error -> %TunnelStorage{}
  end

  @spec clear_storage :: :ok | {:error, Error.t()}
  def clear_storage do
    StorageManager.clear_storage(@context)
  end

  @spec save_storage(TunnelStorage.t()) :: :ok | {:error, Errot.t()}
  def save_storage(%TunnelStorage{} = config) do
    StorageManager.save_storage(@context, config)
  end

  defdelegate has_config?(storage, name), to: Getter
  defdelegate get_config(storage, name), to: Getter
  defdelegate add_config(storage, from, name, reference), to: Setter
  defdelegate edit_config(storage, current_name, from, name, reference), to: Setter
  defdelegate remove_config(storage, name), to: Setter
  defdelegate get_default_config(storage, path), to: DefaultGetter
  defdelegate get_global_default_config(storage), to: DefaultGetter
  defdelegate set_default_config(storage, name, path), to: DefaultSetter
  defdelegate unset_default_config(storage, path), to: DefaultSetter
end

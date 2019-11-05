defmodule RitCLI.Config.Tunnel.Remove do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta

  import RitCLI.Config.Tunnel.ArgumentsParser, only: [parse_name: 1]

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel remove command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle(meta, arg)
      _error -> {:error, empty_argument_error(meta)}
    end
  end

  defp handle(meta, arg) do
    case arg do
      "help" -> {:ok, Meta.help(meta)}
      name -> parse_and_remove(meta, name)
    end
  end

  defp parse_and_remove(meta, name) do
    case parse_name(name) do
      {:ok, name} -> remove(meta, name)
      {:error, error} -> {:error, remove_failure_error(meta, error)}
    end
  end

  defp remove(meta, name) do
    storage = TunnelStorage.get_storage()

    with {:ok, storage} <- TunnelStorage.remove_config(storage, name),
         :ok <- TunnelStorage.save_storage(storage) do
      {:ok, Meta.success(meta, "tunnel config '%{name}' removed", name: name)}
    else
      {:error, error} -> {:error, remove_failure_error(meta, error)}
    end
  end

  defp remove_failure_error(meta, error), do: Meta.error(meta, error)

  defp empty_argument_error(meta) do
    meta
    |> Meta.error(:empty_argument, "a name must be provided")
    |> Meta.help()
  end
end

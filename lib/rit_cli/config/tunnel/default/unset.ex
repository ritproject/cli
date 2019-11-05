defmodule RitCLI.Config.Tunnel.Default.Unset do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta

  import RitCLI.Config.Tunnel.ArgumentsParser, only: [parse_path: 1]

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel default unset command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case Meta.args(meta, 2) do
      {:ok, meta, args} -> handle(meta, args)
      _error -> handle(meta, [])
    end
  end

  defp handle(meta, args) do
    case args do
      ["help" | _args] -> {:ok, Meta.help(meta)}
      ["--path", path] -> parse_and_unset(meta, path)
      [] -> parse_and_unset(meta)
      _unknown -> {:error, invalid_arguments_error(meta)}
    end
  end

  defp parse_and_unset(meta) do
    unset(meta, "*")
  end

  defp parse_and_unset(meta, path) do
    case parse_path(path) do
      {:ok, path} -> unset(meta, path)
      {:error, error} -> {:error, unset_failure_error(meta, error)}
    end
  end

  defp unset(meta, path) do
    storage = TunnelStorage.get_storage()

    with {:ok, storage} <- TunnelStorage.unset_default_config(storage, path),
         :ok <- TunnelStorage.save_storage(storage) do
      {:ok, successfully_unset_result(meta, path)}
    else
      {:error, error} -> {:error, unset_failure_error(meta, error)}
    end
  end

  defp successfully_unset_result(meta, path) do
    if path == "*" do
      Meta.success(meta, "unset global default tunnel config")
    else
      Meta.success(meta, "unset default tunnel config on path '%{path}'", path: path)
    end
  end

  defp unset_failure_error(meta, error), do: Meta.error(meta, error)

  defp invalid_arguments_error(meta) do
    Meta.error(meta, :invalid_arguments, "only valid --path option is allowed")
  end
end

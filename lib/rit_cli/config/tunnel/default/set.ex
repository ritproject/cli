defmodule RitCLI.Config.Tunnel.Default.Set do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta

  import RitCLI.Config.Tunnel.ArgumentsParser,
    only: [
      parse_name: 1,
      parse_path: 1
    ]

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel default set command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case Meta.args(meta, 3) do
      {:ok, meta, args} -> handle(meta, args)
      _error -> {:error, empty_arguments_error(meta)}
    end
  end

  defp handle(meta, args) do
    case args do
      ["help" | _args] -> {:ok, Meta.help(meta)}
      [name] -> parse_and_set(meta, name)
      [name, "--path", path] -> parse_and_set(meta, name, path)
      _args -> {:error, invalid_arguments_error(meta)}
    end
  end

  defp parse_and_set(meta, name) do
    case parse_name(name) do
      {:ok, name} -> set(meta, name, "*")
      {:error, error} -> {:error, set_failure_error(meta, error)}
    end
  end

  defp parse_and_set(meta, name, path) do
    with {:ok, name} <- parse_name(name),
         {:ok, path} <- parse_path(path) do
      set(meta, name, path)
    else
      {:error, error} -> {:error, set_failure_error(meta, error)}
    end
  end

  defp set(meta, name, path) do
    storage = TunnelStorage.get_storage()

    with {:ok, storage} <- TunnelStorage.set_default_config(storage, name, path),
         :ok <- TunnelStorage.save_storage(storage) do
      {:ok, successfully_set_result(meta, name, path)}
    else
      {:error, error} -> {:error, set_failure_error(meta, error)}
    end
  end

  defp successfully_set_result(meta, name, path) do
    if path == "*" do
      Meta.success(meta, "tunnel config '%{name}' set as global default", name: name)
    else
      Meta.success(
        meta,
        "tunnel config '%{name}' set as default on path '%{path}'",
        name: name,
        path: path
      )
    end
  end

  defp set_failure_error(meta, error), do: Meta.error(meta, error)

  defp empty_arguments_error(meta) do
    meta
    |> Meta.error(:empty_arguments, "at least name must be provided")
    |> Meta.help()
  end

  defp invalid_arguments_error(meta) do
    Meta.error(meta, :invalid_arguments, "at least a valid name must be provided")
  end
end

defmodule RitCLI.Config.Tunnel.Add do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta

  import RitCLI.Config.Tunnel.ArgumentsParser,
    only: [
      maybe_extract_name_from_reference: 2,
      parse_from: 1,
      parse_name: 1,
      parse_reference: 2
    ]

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel add command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case Meta.args(meta, 4) do
      {:ok, meta, args} -> handle(meta, args)
      _error -> {:error, empty_arguments_error(meta)}
    end
  end

  defp handle(meta, args) do
    case args do
      ["help" | _args] -> {:ok, Meta.help(meta)}
      [from, reference] -> parse_and_add(meta, from, reference)
      [from, reference, "--name", name] -> parse_and_add(meta, from, reference, name)
      _args -> {:error, invalid_arguments_error(meta)}
    end
  end

  defp parse_and_add(meta, from, reference, name \\ "") do
    with {:ok, from} <- parse_from(from),
         {:ok, reference} <- parse_reference(reference, from),
         {:ok, name} <- parse_name(maybe_extract_name_from_reference(name, reference)) do
      add(meta, from, name, reference)
    else
      {:error, error} -> {:error, add_failure_error(meta, error)}
    end
  end

  defp add(meta, from, name, reference) do
    storage = TunnelStorage.get_storage()

    with {:ok, storage} <- TunnelStorage.add_config(storage, from, name, reference),
         :ok <- TunnelStorage.save_storage(storage) do
      {:ok, Meta.success(meta, "tunnel config '%{name}' saved", name: name)}
    else
      {:error, error} -> {:error, add_failure_error(meta, error)}
    end
  end

  defp add_failure_error(meta, error), do: Meta.error(meta, error)

  defp empty_arguments_error(meta) do
    meta
    |> Meta.error(:empty_arguments, "at least from and reference arguments must be provided")
    |> Meta.help()
  end

  defp invalid_arguments_error(meta) do
    Meta.error(meta, :invalid_arguments, "at least from and reference arguments must be provided")
  end
end

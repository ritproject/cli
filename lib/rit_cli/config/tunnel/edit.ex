defmodule RitCLI.Config.Tunnel.Edit do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta
  alias RitCLI.Meta.Error

  import RitCLI.Config.Tunnel.ArgumentsParser,
    only: [
      maybe_extract_name_from_reference: 2,
      parse_from: 1,
      parse_name: 1,
      parse_name: 2,
      parse_reference: 2
    ]

  @strict_options from: :string, name: :string, reference: :string

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel edit command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case Meta.args(meta, 7) do
      {:ok, meta, ["help" | _args]} -> {:ok, Meta.help(meta)}
      {:ok, meta, args} -> handle(meta, args)
      _error -> {:error, empty_arguments_error(meta)}
    end
  end

  defp handle(meta, args) do
    case OptionParser.parse(args, strict: @strict_options) do
      {parsed, [current_name | _], []} -> parse_and_edit(meta, current_name, parsed)
      _args -> {:error, invalid_arguments_error(meta)}
    end
  end

  defp parse_and_edit(meta, current_name, options) do
    with {:ok, current_name} <- parse_name(current_name, :current_name),
         {:ok, from} <- maybe_parse_from(Keyword.get(options, :from, "")),
         {:ok, reference} <- maybe_parse_reference(Keyword.get(options, :reference, ""), from),
         {:ok, name} <- maybe_parse_name(Keyword.get(options, :name, ""), reference),
         :ok <- at_least_one_optional(name, from, reference) do
      edit(meta, current_name, from, name, reference)
    else
      {:error, error} -> {:error, edit_failure_error(meta, error)}
    end
  end

  defp edit(meta, current_name, from, name, reference) do
    storage = TunnelStorage.get_storage()

    with {:ok, storage} <-
           TunnelStorage.edit_config(storage, current_name, from, name, reference),
         :ok <- TunnelStorage.save_storage(storage) do
      if name == current_name do
        {:ok, Meta.success(meta, "tunnel config '%{name}' updated", name: name)}
      else
        {
          :ok,
          Meta.success(
            meta,
            "tunnel config '%{name}' (previously named '%{previous_name}') updated",
            name: name,
            previous_name: current_name
          )
        }
      end
    else
      {:error, error} -> {:error, edit_failure_error(meta, error)}
    end
  end

  defp maybe_parse_from(""), do: {:ok, ""}
  defp maybe_parse_from(from), do: parse_from(from)

  defp maybe_parse_name(name, reference) do
    case maybe_extract_name_from_reference(name, reference) do
      "" -> {:ok, ""}
      name -> parse_name(name)
    end
  end

  defp maybe_parse_reference("", _from), do: {:ok, ""}
  defp maybe_parse_reference(_reference, ""), do: {:error, reference_without_from_error()}
  defp maybe_parse_reference(reference, from), do: parse_reference(reference, from)

  defp at_least_one_optional("", "", "") do
    {
      :error,
      Error.build(
        __MODULE__,
        :empty_options,
        "at least one valid option must be provided"
      )
    }
  end

  defp at_least_one_optional(_name, _from, _reference) do
    :ok
  end

  defp edit_failure_error(meta, error), do: Meta.error(meta, error)

  defp empty_arguments_error(meta) do
    meta
    |> Meta.error(:empty_arguments, "at least current name argument must be provided")
    |> Meta.help()
  end

  defp invalid_arguments_error(meta) do
    Meta.error(meta, :invalid_arguments, "only valid current name and options must be provided")
  end

  defp reference_without_from_error do
    Error.build(
      __MODULE__,
      :argument_invalid,
      "in order to change 'reference', it is required to set 'from' argument"
    )
  end
end

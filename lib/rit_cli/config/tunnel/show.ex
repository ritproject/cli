defmodule RitCLI.Config.Tunnel.Show do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta
  alias RitCLI.Meta.Output

  import RitCLI.Config.Tunnel.ArgumentsParser, only: [parse_name: 1]

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel show command selected")
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
      name -> parse_and_show(meta, name)
    end
  end

  defp parse_and_show(meta, name) do
    case parse_name(name) do
      {:ok, name} -> show_config(meta, name)
      {:error, error} -> {:error, show_failure_error(meta, error)}
    end
  end

  defp show_config(meta, name) do
    storage = TunnelStorage.get_storage()

    case TunnelStorage.get_config(storage, name) do
      {:ok, config} -> show(meta, storage, config, name)
      {:error, error} -> {:error, show_failure_error(meta, error)}
    end
  end

  defp show(meta, storage, config, name) do
    meta =
      if meta.main.output_mode == :plain do
        show_plain_config(meta, storage, config, name)
      else
        Meta.set_output_data(meta, build_data_config(storage, config, name))
      end

    {:ok, Meta.log(meta, :success, "config tunnel show handled")}
  end

  defp show_plain_config(meta, %{defaults: defaults}, config, name) do
    message = """
    - name: #{name}
    - from: #{config.from}
    - reference: #{config.reference}
    """

    message =
      if Enum.empty?(defaults) do
        message
      else
        message <>
          "- default_paths:\n" <>
          Enum.reduce(defaults, "", fn {path, config_name}, message ->
            if config_name == name do
              message <>
                if path == :* do
                  "    - (global)\n"
                else
                  "    - #{path}"
                end
            else
              message
            end
          end)
      end

    Output.show_plain(message)

    meta
  end

  defp build_data_config(%{defaults: defaults}, config, name) do
    data = %{
      name: name,
      from: config.from,
      reference: config.reference
    }

    if Enum.empty?(defaults) do
      data
    else
      paths =
        Enum.reduce(defaults, [], fn {path, config_name}, paths ->
          if config_name == name do
            [path] ++ paths
          else
            paths
          end
        end)

      if Enum.empty?(paths) do
        data
      else
        Map.put(data, :paths, Enum.reverse(paths))
      end
    end
  end

  defp show_failure_error(meta, error), do: Meta.error(meta, error)

  defp empty_argument_error(meta) do
    meta
    |> Meta.error(:empty_argument, "a name must be provided")
    |> Meta.help()
  end
end

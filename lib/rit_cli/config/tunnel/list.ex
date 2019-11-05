defmodule RitCLI.Config.Tunnel.List do
  @moduledoc false

  alias RitCLI.Config.TunnelStorage
  alias RitCLI.Meta
  alias RitCLI.Meta.Output

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(%Meta{} = meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "config tunnel list command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, "help"} -> {:ok, Meta.help(meta)}
      {:error, :nothing_to_parse} -> list(meta, TunnelStorage.get_storage())
      _error -> {:error, unknown_arguments_error(meta)}
    end
  end

  defp list(meta, storage) do
    meta =
      if meta.main.output_mode == :plain do
        show_plain_storage(meta, storage)
      else
        Meta.set_output_data(meta, build_data_storage(storage))
      end

    {:ok, Meta.log(meta, :success, "config tunnel list handled")}
  end

  defp show_plain_storage(meta, %{configs: configs, defaults: defaults}) do
    message =
      if Enum.empty?(configs) do
        "There are no tunnel configs set"
      else
        configs = """
        # Tunnels Configs

        #{Enum.reduce(configs, "", &config_message/2)}
        """

        if Enum.empty?(defaults) do
          configs <> "There are no default tunnel configs set\n"
        else
          configs <>
            """
            ## Default Paths

            #{Enum.reduce(defaults, "", &default_message/2)}
            """
        end
      end

    Output.show_plain(message)

    meta
  end

  defp config_message({name, %{from: from, reference: reference}}, message) do
    message <> "- #{to_string(name)}: #{reference} (#{from})\n"
  end

  defp default_message({path, tunnel_name}, message) do
    path = if path == :*, do: "(global)", else: to_string(path)
    message <> "- #{path}: #{tunnel_name}\n"
  end

  defp build_data_storage(%{configs: configs, defaults: defaults}) do
    default_paths =
      Enum.reduce(defaults, %{}, fn {path, name}, default_paths ->
        paths = Map.get(default_paths, name, [])
        Map.put(default_paths, name, [Atom.to_string(path)] ++ paths)
      end)

    Enum.reduce(configs, [], fn {name, %{from: from, reference: reference}}, configs ->
      name = Atom.to_string(name)

      case Map.get(default_paths, name) do
        nil -> [%{from: from, name: name, reference: reference}] ++ configs
        paths -> [%{from: from, name: name, paths: paths, reference: reference}] ++ configs
      end
    end)
    |> Enum.reverse()
  end

  defp unknown_arguments_error(meta) do
    meta
    |> Meta.error(:unknown_arguments, "only help is allowed as argument")
    |> Meta.help()
  end
end

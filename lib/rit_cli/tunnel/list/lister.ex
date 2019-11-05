defmodule RitCLI.Tunnel.List.Lister do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Meta.Output
  alias RitCLI.Tunnel.List.Lister
  alias RitCLI.Tunnel.Run.RunParser
  alias RitCLI.Tunnel.SettingsManager

  defstruct args: [],
            commands: %{},
            current_depth: 0,
            depth: :infinity,
            path: [],
            prefix: [],
            settings: %{},
            source_path: ""

  @spec list(Meta.t(), map, String.t(), integer) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def list(%Meta{} = meta, settings, source_path, depth) do
    case RunParser.parse(settings) do
      {:ok, child_settings} -> do_run(meta, child_settings, source_path, depth)
      {:error, error} -> {:error, run_key_not_found(meta, error)}
    end
  end

  defp do_run(%{args: %{to_parse: to_parse}} = meta, settings, source_path, depth) do
    lister = %Lister{
      args: to_parse,
      depth: depth,
      prefix: to_parse,
      settings: settings,
      source_path: source_path
    }

    case follow_args(meta, lister) do
      {:ok, meta, lister} -> map_commands(meta, lister)
      error -> error
    end
  end

  defp follow_args(meta, lister) do
    if Enum.empty?(lister.args) do
      {:ok, meta, lister}
    else
      do_follow_args(meta, lister)
    end
  end

  defp do_follow_args(meta, %{args: [arg | args], settings: settings} = lister) do
    if is_map(settings) do
      case Map.get(settings, ".#{arg}") do
        nil -> {:error, unknown_command_argument_error(meta, arg)}
        settings -> check_settings_and_follow_args(meta, lister, settings, args, arg)
      end
    else
      {:error, unknown_command_argument_error(meta, arg)}
    end
  end

  defp check_settings_and_follow_args(meta, lister, settings, args, arg) do
    if is_map(settings) and Map.has_key?(settings, "redirect") do
      redirect = Map.get(settings, "redirect")

      if is_map(redirect) and Map.get(redirect, "external") do
        fetch_external_and_follow_args(meta, lister, Map.get(redirect, "to"), args, arg)
      else
        follow_args(meta, update_args(lister, settings, args, arg))
      end
    else
      follow_args(meta, update_args(lister, settings, args, arg))
    end
  end

  defp fetch_external_and_follow_args(meta, lister, to, args, arg) do
    path = Path.expand(to, lister.source_path)

    case SettingsManager.extract(meta, path) do
      {:ok, settings} -> parse_redirect_and_follow_args(meta, lister, settings, args, arg)
      error -> error
    end
  end

  defp parse_redirect_and_follow_args(meta, lister, settings, args, arg) do
    case RunParser.parse(settings) do
      {:ok, settings} -> follow_args(meta, update_args(lister, settings, args, arg))
      {:error, error} -> {:error, run_key_not_found(meta, error)}
    end
  end

  defp update_args(lister, settings, args, arg) do
    struct(lister, args: args, path: lister.path ++ [arg], settings: settings)
  end

  defp map_commands(meta, lister) do
    case do_map_commands(meta, lister) do
      {:ok, meta, lister} -> {:ok, show_commands(meta, lister)}
      error -> error
    end
  end

  defp do_map_commands(meta, %{settings: settings} = lister) do
    cond do
      is_map(settings) -> map_keys(meta, lister, Map.keys(settings))
      is_binary(settings) -> {:ok, meta, map_command(lister, :run)}
      is_list(settings) -> {:ok, meta, map_command(lister, :run)}
      true -> {:ok, meta, lister}
    end
  end

  defp map_keys(meta, lister, [key | keys]) do
    case key do
      "." <> arg -> map_arg_and_continue(meta, lister, arg, keys)
      _key -> map_key_and_continue(meta, lister, key, keys)
    end
  end

  defp map_keys(meta, lister, _keys) do
    {:ok, meta, lister}
  end

  defp map_arg_and_continue(meta, %{current_depth: current, depth: depth} = lister, arg, keys) do
    if depth == :infinity or current < depth do
      do_map_arg_and_continue(meta, struct(lister, current_depth: current + 1), arg, keys)
    else
      map_keys(meta, lister, keys)
    end
  end

  defp do_map_arg_and_continue(meta, %{settings: settings, path: path} = lister, arg, keys) do
    lister =
      struct(
        lister,
        path: path ++ [arg],
        settings: Map.get(lister.settings, ".#{arg}")
      )

    case do_map_commands(meta, lister) do
      {:ok, meta, lister} -> map_keys(meta, struct(lister, path: path, settings: settings), keys)
      error -> error
    end
  end

  defp map_key_and_continue(meta, lister, "direct", keys) do
    map_keys(meta, map_command(lister, :direct), keys)
  end

  defp map_key_and_continue(meta, lister, "redirect", keys) do
    lister = map_command(lister, :redirect)

    case Map.get(lister.settings, "redirect", %{}) do
      %{"to" => to, "external" => true} -> fetch_external_and_continue(meta, lister, to)
      _redirect -> map_keys(meta, lister, keys)
    end
  end

  defp map_key_and_continue(meta, lister, "run", keys) do
    map_keys(meta, map_command(lister, :run), keys)
  end

  defp map_key_and_continue(meta, lister, _key, keys) do
    map_keys(meta, lister, keys)
  end

  defp map_command(lister, operation_key) do
    struct(
      lister,
      commands: map_command_key(lister.commands, lister.path, operation_key)
    )
  end

  defp map_command_key(commands, [key | path], operation_key) do
    Map.put(commands, key, map_command_key(Map.get(commands, key, %{}), path, operation_key))
  end

  defp map_command_key(commands, [], operation_key) do
    Map.put(commands, operation_key, true)
  end

  defp fetch_external_and_continue(meta, lister, to) do
    path = Path.expand(to, lister.source_path)

    case SettingsManager.extract(meta, path) do
      {:ok, settings} -> parse_run_and_continue(meta, struct(lister, source_path: path), settings)
      error -> error
    end
  end

  defp parse_run_and_continue(meta, lister, settings) do
    case RunParser.parse(settings) do
      {:ok, settings} -> do_map_commands(meta, struct(lister, settings: settings))
      {:error, error} -> {:error, run_key_not_found(meta, error)}
    end
  end

  defp show_commands(meta, lister) do
    if meta.main.output_mode == :plain do
      show_plain(struct(lister, path: []))
      meta
    else
      Meta.set_output_data(meta, lister.commands)
    end
  end

  defp show_plain(lister) do
    message =
      if Enum.empty?(lister.commands) do
        "There are no commands set on setting"
      else
        String.trim(commands_message(lister))
      end

    Output.show_plain(message)
  end

  defp commands_message(%{commands: commands} = lister, message \\ "") do
    run_options_message =
      ""
      |> maybe_concat_key(Map.has_key?(commands, :direct), "direct")
      |> maybe_concat_key(Map.has_key?(commands, :redirect), "redirect")
      |> maybe_concat_key(Map.has_key?(commands, :run), "run")

    message =
      if run_options_message != "" do
        message <> "  (" <> run_options_message <> ")"
      else
        message
      end

    commands = Map.drop(commands, [:direct, :redirect, :run])

    if Enum.empty?(commands) do
      message
    else
      child_commands_message(struct(lister, commands: commands), message, Map.keys(commands))
    end
  end

  defp maybe_concat_key("", true, key), do: key
  defp maybe_concat_key(message, true, key), do: message <> ", " <> key
  defp maybe_concat_key(message, false, _key), do: message

  defp child_commands_message(%{commands: commands, path: path} = lister, message, [key | keys]) do
    path = path ++ [key]
    message = message <> "\n- #{Enum.join(path, " ")}\n"

    message =
      lister
      |> struct(commands: Map.get(commands, key), path: path)
      |> commands_message(message)

    child_commands_message(lister, message, keys)
  end

  defp child_commands_message(_lister, message, []) do
    message
  end

  defp run_key_not_found(meta, error), do: Meta.error(meta, error)

  defp unknown_command_argument_error(meta, arg) do
    Meta.error(
      meta,
      :argument_not_found,
      "while following arguments on setting file, the '%{arg}' could not be found",
      arg: arg
    )
  end
end

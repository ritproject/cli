defmodule RitCLI.CLI.Tunnel.Manager.Runner do
  @moduledoc false

  alias RitCLI.CLI.{Error, Output}
  alias RitCLI.CLI.Tunnel.Manager
  alias RitCLI.CLI.Tunnel.Manager.Runner

  defstruct root_settings: %{},
            root_arguments: [],
            path: "",
            external_prefixes: [],
            prefixes: [],
            settings: %{},
            arguments: [],
            operation: nil,
            link_dir: "",
            link_mode: :copy,
            environment: %{},
            strict?: false

  @id :tunnel_runner

  @spec run(map, list(String.t()), String.t()) :: :ok | {:error, atom, Output.t()}
  def run(settings, arguments, path) do
    runner = %Runner{path: path, root_arguments: arguments, root_settings: settings}

    case Map.get(settings, "run") do
      nil -> Error.build_error(@id, :root_run_undefined)
      settings -> do_run(update_runner(runner, settings, arguments))
    end
  end

  defp update_runner(%Runner{} = runner, settings, arguments) do
    struct(runner, arguments: arguments, settings: settings)
    |> update_parameters()
    |> update_operations()
  end

  defp update_parameters(%Runner{} = runner) do
    runner
    |> maybe_update_link_dir()
    |> maybe_update_link_mode()
    |> maybe_update_environment()
  end

  defp maybe_update_link_dir(%Runner{settings: settings} = runner) do
    if is_map(settings) do
      case Map.get(settings, "link_dir") do
        nil -> runner
        link_dir -> struct(runner, link_dir: link_dir)
      end
    else
      runner
    end
  end

  defp maybe_update_link_mode(%Runner{settings: settings} = runner) do
    if is_map(settings) do
      case Map.get(settings, "link_mode") do
        "copy" -> struct(runner, link_mode: :copy)
        "symlink" -> struct(runner, link_mode: :symlink)
        _unknown -> runner
      end
    else
      runner
    end
  end

  defp maybe_update_environment(%Runner{settings: settings} = runner) do
    if is_map(settings) do
      case Map.get(settings, "environment") do
        nil -> runner
        environment -> struct(runner, environment: Map.merge(runner.environment, environment))
      end
    else
      runner
    end
  end

  defp update_operations(%Runner{} = runner) do
    runner
    |> maybe_update_if_list_or_string()
    |> maybe_update_from_run()
    |> maybe_update_from_arguments()
    |> maybe_update_from_direct()
    |> maybe_update_from_redirect()
  end

  defp maybe_update_if_list_or_string(%Runner{operation: nil, settings: operation} = runner)
       when is_binary(operation)
       when is_list(operation) do
    struct(runner, operation: {:execute, operation})
  end

  defp maybe_update_if_list_or_string(%Runner{} = runner) do
    runner
  end

  defp maybe_update_from_run(%Runner{operation: nil, settings: settings} = runner) do
    case Map.get(settings, "run") do
      nil ->
        runner

      operation ->
        if runner.strict? do
          if Enum.empty?(runner.arguments) do
            struct(runner, operation: {:execute, operation})
          else
            runner
          end
        else
          if Enum.empty?(runner.arguments) do
            struct(runner, operation: {:execute, operation})
          else
            struct(runner, operation: {:execute_and_continue, operation})
          end
        end
    end
  end

  defp maybe_update_from_run(%Runner{} = runner) do
    runner
  end

  defp maybe_update_from_arguments(%Runner{arguments: [arg | args]} = runner) do
    if is_map(runner.settings) do
      case Map.get(runner.settings, ".#{arg}") do
        nil ->
          runner

        settings ->
          prefixes = runner.prefixes ++ [arg]

          case runner.operation do
            {:execute_and_continue, operation} ->
              struct(runner,
                operation: {:execute_and_continue, operation, {prefixes, settings, args}}
              )

            _operation ->
              update_runner(struct(runner, prefixes: prefixes), settings, args)
          end
      end
    else
      runner
    end
  end

  defp maybe_update_from_arguments(%Runner{} = runner) do
    runner
  end

  defp maybe_update_from_direct(%Runner{operation: nil, arguments: []} = runner) do
    case Map.get(runner.settings, "direct") do
      nil -> runner
      operation -> struct(runner, operation: {:execute, operation})
    end
  end

  defp maybe_update_from_direct(%Runner{} = runner) do
    runner
  end

  defp maybe_update_from_redirect(%Runner{operation: nil, settings: settings} = runner) do
    case Map.get(settings, "redirect") do
      nil -> runner
      redirect -> struct(runner, operation: {:redirect, redirect})
    end
  end

  defp maybe_update_from_redirect(%Runner{} = runner) do
    runner
  end

  defp do_run(%Runner{operation: operation} = runner) do
    runner = struct(runner, operation: nil)

    case operation do
      {:execute, operation} -> execute(operation, runner)
      {:execute_and_continue, operation, cache} -> execute_and_continue(operation, runner, cache)
      {:redirect, redirect} -> apply_redirect(runner, redirect)
      _unknown -> Error.build_error(@id, :operation_undefined)
    end
  end

  defp execute(operation, %Runner{environment: environment, path: path} = runner) do
    if runner.link_dir != "" do
      tunnel_path = Path.expand(runner.link_dir, path)
      File.rm_rf(tunnel_path)
      perform_link!(runner, tunnel_path)

      case operation do
        operation when is_binary(operation) ->
          execute_operation(operation, environment, path)

        operations when is_list(operations) ->
          Enum.reduce_while(operations, :ok, fn operation, _result ->
            case execute_operation(operation, environment, path) do
              :ok -> {:cont, :ok}
              error -> {:halt, error}
            end
          end)
      end
    else
      Error.build_error(@id, :link_dir_undefined)
    end
  rescue
    _error -> Error.build_error(@id, :link_failed)
  end

  defp perform_link!(%Runner{link_mode: :symlink}, tunnel_path) do
    File.ln_s!(Path.expand("."), tunnel_path)
  end

  defp perform_link!(%Runner{link_mode: :copy}, tunnel_path) do
    File.cp_r!(Path.expand("."), tunnel_path)
  end

  defp execute_operation(operation, environment, path) do
    [command | arguments] =
      operation
      |> interpolate_envs(environment)
      |> String.split(" ", trim: true)

    environment = Enum.map(environment, fn {key, value} -> {key, value} end)

    {result, code} =
      File.cd!(path, fn ->
        System.cmd(command, arguments, env: environment, stderr_to_stdout: true)
      end)

    Output.inform(%Output{message: result})

    if code == 0 do
      :ok
    else
      Error.build_error(@id, :operation_failed, code: code, operation: operation)
    end
  rescue
    _error -> Error.build_error(@id, :operation_failed, code: 1, operation: operation)
  end

  defp interpolate_envs(operation, environment) do
    Regex.replace(~r/\$[{]*(\w+)[}]*/, operation, fn _match, env ->
      case Map.get(environment, env) do
        nil -> System.get_env(env, "")
        env -> env
      end
    end)
  end

  defp execute_and_continue(operation, %Runner{} = runner, {prefixes, settings, args}) do
    case execute(operation, runner) do
      :ok -> do_run(update_runner(struct(runner, prefixes: prefixes), settings, args))
      error -> error
    end
  end

  defp apply_redirect(%Runner{} = runner, %{"to" => to} = redirect) do
    runner =
      if runner.strict? do
        runner
      else
        struct(runner, strict?: Map.get(redirect, "strict", false))
      end

    if Map.get(redirect, "external", false) do
      path = Path.expand(to, runner.path)

      case Manager.extract_settings(path) do
        {:ok, settings} ->
          runner = merge_settings(runner, Map.get(settings, "run", %{}))

          struct(runner, path: path)
          |> update_runner(runner.settings, runner.root_arguments)
          |> do_run()

        error ->
          error
      end
    else
      arguments = runner.external_prefixes ++ String.split(to, " ")
      runner = struct(runner, prefixes: [])
      root_run_settings = Map.get(runner.root_settings, "run")
      do_run(update_runner(runner, root_run_settings, arguments))
    end
  end

  defp merge_settings(runner, settings) do
    root_run_settings =
      runner.root_settings
      |> Map.get("run", %{})
      |> do_merge_settings(settings, runner.prefixes)

    root_settings = Map.put(runner.root_settings, "run", root_run_settings)

    struct(runner,
      external_prefixes: runner.prefixes,
      prefixes: [],
      root_settings: root_settings,
      settings: root_run_settings
    )
  end

  defp do_merge_settings(_source, settings, []) do
    settings
  end

  defp do_merge_settings(source, settings, [prefix | []]) do
    Map.put(source, ".#{prefix}", settings)
  end

  defp do_merge_settings(source, settings, [prefix | prefixes]) do
    prefix = ".#{prefix}"
    Map.put(source, prefix, do_merge_settings(Map.get(source, prefix), settings, prefixes))
  end
end

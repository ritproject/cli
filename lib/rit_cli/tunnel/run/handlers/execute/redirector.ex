defmodule RitCLI.Tunnel.Run.Handler.Execute.Redirector do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.Run.{RunHandler, Runner}
  alias RitCLI.Tunnel.SettingsManager

  @spec redirect(Meta.t(), Runner.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def redirect(%Meta{} = meta, %Runner{} = runner) do
    redirect = runner.operation

    runner =
      if runner.strict? do
        runner
      else
        if Map.get(redirect, "strict", false) do
          struct(runner, strict?: true)
        else
          struct(runner, strict?: false)
        end
      end

    to = Map.get(redirect, "to")

    if Map.get(redirect, "external") do
      path = Path.expand(to, runner.source_path)

      case SettingsManager.extract(meta, path) do
        {:ok, settings} ->
          runner =
            runner
            |> merge_settings(Map.get(settings, "run", %{}))
            |> struct(source_path: path, operation: nil, operation_mode: nil)

          RunHandler.handle(meta, runner, runner.settings, runner.root_args)

        error ->
          error
      end
    else
      args = runner.external_prefixes ++ String.split(to, " ")
      runner = struct(runner, opreation: nil, operation_mode: nil, prefixes: [])
      root_run_settings = Map.get(runner.root_settings, "run")
      RunHandler.handle(meta, runner, root_run_settings, args)
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

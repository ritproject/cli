defmodule RitCLI.Tunnel.Run.Runner do
  @moduledoc false

  alias RitCLI.Meta

  alias RitCLI.Tunnel.Run.{
    RunHandler,
    Runner,
    RunParser
  }

  @type t :: %Runner{
          args: list(String.t()),
          environment: map,
          external_prefixes: list(String.t()),
          input: map,
          input_mode: atom,
          link_dir: String.t(),
          link_mode: atom,
          operation: list(String.t()) | String.t() | nil,
          operation_cache: map | nil,
          operation_mode: atom,
          prefixes: list(String.t()),
          root_args: list(String.t()),
          root_settings: map,
          settings: map,
          source_path: String.t(),
          strict?: boolean,
          target_path: String.t()
        }

  defstruct args: [],
            environment: %{},
            external_prefixes: [],
            input: %{},
            input_mode: :enabled,
            link_dir: "",
            link_mode: :none,
            operation: nil,
            operation_cache: nil,
            operation_mode: nil,
            prefixes: [],
            root_args: [],
            root_settings: %{},
            settings: %{},
            source_path: "",
            strict?: false,
            target_path: ""

  @spec run(Meta.t(), map, String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def run(%Meta{} = meta, settings, source_path) do
    case RunParser.parse(settings) do
      {:ok, child_settings} -> do_run(meta, settings, source_path, child_settings)
      {:error, error} -> {:error, run_key_not_found(meta, error)}
    end
  end

  defp do_run(%{tunnel: tunnel} = meta, root_settings, source_path, settings) do
    args = meta.args.to_parse

    runner = %Runner{
      input_mode: tunnel.input_mode,
      source_path: source_path,
      target_path: tunnel.path,
      root_args: args,
      root_settings: root_settings
    }

    RunHandler.handle(meta, runner, settings, args)
  end

  defp run_key_not_found(meta, error), do: Meta.error(meta, error)
end

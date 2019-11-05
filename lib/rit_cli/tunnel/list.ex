defmodule RitCLI.Tunnel.List do
  @moduledoc false

  alias RitCLI.Meta
  alias RitCLI.Tunnel.List.Lister
  alias RitCLI.Tunnel.{SettingsManager, SourceManager}

  @spec handle_arguments(Meta.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_arguments(meta) do
    meta
    |> Meta.module(__MODULE__)
    |> Meta.log(:info, "tunnel list command selected")
    |> do_handle_arguments()
  end

  defp do_handle_arguments(meta) do
    case meta.args.to_parse do
      ["--depth"] -> {:error, invalid_depth_error(meta)}
      ["--depth", depth | _to_parse] -> handle_depth_and_list(meta, depth)
      _to_parse -> list(meta)
    end
  end

  defp handle_depth_and_list(meta, depth) do
    if depth != "infinity" do
      depth = String.to_integer(depth)

      if depth > 0 do
        {:ok, meta, _args} = Meta.args(meta, 2)
        list(meta, depth)
      else
        {:error, invalid_depth_error(meta)}
      end
    else
      {:ok, meta, _args} = Meta.args(meta, 2)
      list(meta, :infinity)
    end
  rescue
    _error -> {:error, invalid_depth_error(meta)}
  end

  defp list(meta, depth \\ :infinity) do
    with {:ok, source_path} <- SourceManager.fetch(meta),
         {:ok, settings} <- SettingsManager.extract(meta, source_path) do
      Lister.list(meta, settings, source_path, depth)
    end
  end

  defp invalid_depth_error(meta) do
    Meta.error(meta, :invalid_depth, "depth value must be a positive number or infinity")
  end
end

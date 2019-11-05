defmodule RitCLI.Tunnel.ModifierHandler do
  @moduledoc false

  alias RitCLI.Tunnel.{
    ArgumentsHandler,
    ConfigParser,
    InputParser,
    ModifierParser,
    PathParser
  }

  alias RitCLI.Meta

  @spec handle_modifier(Meta.t(), String.t()) :: {:ok, Meta.t()} | {:error, Meta.t()}
  def handle_modifier(%Meta{} = meta, value) do
    case ModifierParser.parse(value) do
      {:ok, modifier} -> handle_modification(meta, modifier)
      {:error, error} -> {:error, invalid_modifier_error(meta, error)}
    end
  end

  defp handle_modification(meta, modifier) do
    case modifier do
      :config -> handle_config_modifier(meta)
      :input -> handle_input_modifier(meta)
      :path -> handle_path_modifier(meta)
    end
  end

  defp handle_config_modifier(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_config(meta, arg)
      _error -> {:error, empty_config_modifier_error(meta)}
    end
  end

  defp handle_config(meta, arg) do
    case ConfigParser.parse(arg) do
      {:ok, config} -> ArgumentsHandler.handle_arguments(Meta.tunnel(meta, config: config))
      {:error, error} -> {:error, invalid_config_error(meta, error)}
    end
  end

  defp handle_input_modifier(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_input_mode(meta, arg)
      _error -> {:error, empty_input_modifier_error(meta)}
    end
  end

  defp handle_input_mode(meta, arg) do
    case InputParser.parse(arg) do
      {:ok, mode} -> ArgumentsHandler.handle_arguments(Meta.tunnel(meta, input_mode: mode))
      {:error, error} -> {:error, invalid_input_error(meta, error)}
    end
  end

  defp handle_path_modifier(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_path(meta, arg)
      _error -> {:error, empty_path_modifier_error(meta)}
    end
  end

  defp handle_path(meta, arg) do
    case PathParser.parse(arg) do
      {:ok, path} -> ArgumentsHandler.handle_arguments(Meta.tunnel(meta, path: path))
      {:error, error} -> {:error, invalid_path_error(meta, error)}
    end
  end

  defp empty_config_modifier_error(meta) do
    Meta.error(meta, :empty_config_modifier, "config name must be provided")
  end

  defp empty_input_modifier_error(meta) do
    Meta.error(meta, :empty_input_modifier, "input mode must be provided")
  end

  defp empty_path_modifier_error(meta) do
    Meta.error(meta, :empty_path_modifier, "path must be provided")
  end

  defp invalid_modifier_error(meta, error), do: Meta.error(meta, error)
  defp invalid_config_error(meta, error), do: Meta.error(meta, error)
  defp invalid_input_error(meta, error), do: Meta.error(meta, error)
  defp invalid_path_error(meta, error), do: Meta.error(meta, error)
end

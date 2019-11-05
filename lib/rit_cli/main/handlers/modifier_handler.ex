defmodule RitCLI.Main.ModifierHandler do
  @moduledoc false

  alias RitCLI.Main.{
    ArgumentsHandler,
    LogModeParser,
    ModifierParser,
    OutputModeParser
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
      :log -> handle_log_modifier(meta)
      :output -> handle_output_modifier(meta)
    end
  end

  defp handle_log_modifier(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_log_mode(meta, arg)
      _error -> {:error, empty_log_modifier_error(meta)}
    end
  end

  defp handle_log_mode(meta, arg) do
    case LogModeParser.parse(arg) do
      {:ok, mode} -> ArgumentsHandler.handle_arguments(Meta.main(meta, log_mode: mode))
      {:error, error} -> {:error, invalid_log_mode_error(meta, error)}
    end
  end

  defp handle_output_modifier(meta) do
    case Meta.args(meta, 1) do
      {:ok, meta, arg} -> handle_output_mode(meta, arg)
      _error -> {:error, empty_output_modifier_error(meta)}
    end
  end

  defp handle_output_mode(meta, arg) do
    case OutputModeParser.parse(arg) do
      {:ok, mode} -> ArgumentsHandler.handle_arguments(Meta.main(meta, output_mode: mode))
      {:error, error} -> {:error, invalid_output_mode_error(meta, error)}
    end
  end

  defp empty_log_modifier_error(meta) do
    Meta.error(meta, :empty_log_modifier, "log mode must be provided")
  end

  defp empty_output_modifier_error(meta) do
    Meta.error(meta, :empty_output_modifier, "output mode must be provided")
  end

  defp invalid_modifier_error(meta, error), do: Meta.error(meta, error)
  defp invalid_log_mode_error(meta, error), do: Meta.error(meta, error)
  defp invalid_output_mode_error(meta, error), do: Meta.error(meta, error)
end

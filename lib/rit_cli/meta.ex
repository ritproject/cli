defmodule RitCLI.Meta do
  @moduledoc false

  alias RitCLI.{Main, Meta, Tunnel}
  alias RitCLI.Meta.{Arguments, Error, Helper, Logs, Output}

  @type t :: %Meta{
          args: Arguments.t(),
          error: Error.t(),
          help?: boolean,
          main: Main.t(),
          module: module,
          logs: Logs.t(),
          output: Output.t(),
          tunnel: Tunnel.t() | nil
        }

  defstruct args: %Arguments{},
            error: %Error{},
            help?: false,
            main: %Main{},
            module: nil,
            logs: %Logs{},
            output: %Output{},
            tunnel: nil

  @spec args(Meta.t(), integer) ::
          {:ok, Meta.t(), list(String.t()) | String.t()}
          | {:error, :empty}
          | {:error, :nothing_to_parse}
  def args(%Meta{} = meta, amount) do
    if meta.args.original_length != 0 do
      if meta.args.to_parse_length != 0 do
        args =
          if amount == 1 do
            Enum.at(meta.args.to_parse, 0)
          else
            Enum.slice(meta.args.to_parse, 0, amount)
          end

        {:ok, %Meta{meta | args: Arguments.update(meta.args, amount)}, args}
      else
        {:error, :nothing_to_parse}
      end
    else
      {:error, :empty}
    end
  end

  @spec create(list(String.t())) :: Meta.t()
  def create(argv) do
    %Meta{args: Arguments.create(argv), logs: Logs.log_start()}
  end

  @spec error(Meta.t(), Error.t()) :: Meta.t()
  def error(%Meta{} = meta, %Error{} = error) do
    error = %Error{error | where: meta.module}

    logs = Logs.add_error(meta.logs, error)

    if meta.main.output_mode == :plain do
      error
      |> Error.to_string(color?: true)
      |> Output.show_plain()
    end

    %Meta{meta | error: error, logs: logs}
  end

  @spec error(Meta.t(), atom, String.t(), keyword | map | nil, integer) :: Meta.t()
  def error(%Meta{} = meta, id, message, metadata \\ nil, exit_code \\ 1) do
    error(meta, Error.build(nil, id, message, metadata, exit_code))
  end

  @spec help(Meta.t()) :: Meta.t()
  def help(%Meta{} = meta) do
    %Meta{meta | help?: true, logs: Logs.add(meta.logs, meta.module, :info, "set to show helper")}
  end

  # @spec info(Meta.t(), String.t(), keyword | map | nil) :: Meta.t()
  # def info(%Meta{} = meta, message, metadata \\ nil) do
  #   if meta.main.output_mode == :plain do
  #     message
  #     |> Output.interpolate_metadata(metadata)
  #     |> Output.show_plain()
  #   end

  #   %Meta{meta | logs: Logs.add(meta.logs, meta.module, :info, message, metadata)}
  # end

  @spec log(Meta.t(), atom, String.t(), keyword | map | nil) :: Meta.t()
  def log(%Meta{} = meta, level, message, metadata \\ nil) do
    %Meta{meta | logs: Logs.add(meta.logs, meta.module, level, message, metadata)}
  end

  @spec main(Meta.t(), keyword) :: Meta.t()
  def main(%Meta{} = meta, data) do
    meta
    |> struct(main: struct(meta.main, data))
    |> log_each(meta.main, :success, data)
  end

  @spec module(Meta.t(), module) :: Meta.t()
  def module(%Meta{} = meta, module) do
    %Meta{meta | module: module}
  end

  @spec set_output_data(Meta.t(), any) :: Meta.t()
  def set_output_data(%Meta{} = meta, data) do
    %Meta{meta | output: Map.put(meta.output, :data, data)}
  end

  @spec show(Meta.t()) :: Meta.t()
  def show(%Meta{} = meta) do
    meta
    |> struct(logs: Logs.log_end(meta.logs))
    |> do_show(meta.main.output_mode)
  end

  @spec success(Meta.t(), String.t(), keyword | map | nil) :: Meta.t()
  def success(%Meta{} = meta, message, metadata \\ nil) do
    if meta.main.output_mode == :plain do
      "[%{success}] %{info}"
      |> Output.interpolate_colors(["success", Output.interpolate_metadata(message, metadata)])
      |> Output.show_plain()
    end

    %Meta{meta | logs: Logs.add(meta.logs, meta.module, :success, message, metadata)}
  end

  @spec tunnel(Meta.t(), keyword) :: Meta.t()
  def tunnel(%Meta{} = meta, data) do
    meta
    |> struct(tunnel: struct(meta.tunnel, data))
    |> log_each(meta.tunnel, :success, data)
  end

  defp log_each(meta, map, level, data) do
    logs =
      Enum.reduce(data, meta.logs, fn {key, value}, logs ->
        case Map.get(map, key) do
          nil ->
            Logs.add(
              logs,
              meta.module,
              level,
              "%{key} set to '%{value}'",
              key: key,
              value: value
            )

          previous_value ->
            Logs.add(
              logs,
              meta.module,
              level,
              "%{key} updated from '%{previous_value}' to '%{value}'",
              key: key,
              previous_value: previous_value,
              value: value
            )
        end
      end)

    %Meta{meta | logs: logs}
  end

  defp do_show(meta, :plain) do
    if meta.help? do
      meta.module
      |> Helper.to_string(color?: true)
      |> Output.show_plain()
    end

    if show_logs?(meta) do
      Output.show_plain("\n# Logs\n")

      meta.logs
      |> Logs.to_string(color?: true)
      |> Output.show_plain()
    end

    meta
  end

  defp do_show(meta, mode) do
    map =
      if meta.output.data do
        %{data: Output.to_map(meta.output)}
      else
        %{}
      end

    map =
      if meta.error.id do
        Map.put(map, :error, Error.to_map(meta.error))
      else
        map
      end

    map =
      if show_logs?(meta) do
        Map.put(map, :logs, Logs.to_map(meta.logs))
      else
        map
      end

    Output.show(mode, map)

    meta
  end

  defp show_logs?(%{main: %{log_mode: log_mode}, error: %{id: id}}) do
    log_mode == :batch or (log_mode == :on_error and id)
  end
end

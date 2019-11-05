defmodule RitCLI.Meta.Logs do
  @moduledoc false

  alias RitCLI.Meta.{Error, Log, Logs}

  @type t :: %Logs{
          length: integer,
          data: list(Log.t())
        }

  defstruct length: 0,
            data: []

  @spec add(Logs.t(), atom, atom, String.t(), map | keyword | nil) :: Logs.t()
  def add(%Logs{} = logs, where, level, message, metadata \\ nil) do
    struct(
      logs,
      data: [Log.create(where, level, message, metadata)] ++ logs.data,
      length: logs.length + 1
    )
  end

  @spec add_error(Logs.t(), Error.t()) :: Logs.t()
  def add_error(%Logs{} = logs, %Error{metadata: metadata} = error) do
    if metadata != nil do
      add(logs, error.where, :error, error.message, Map.put(metadata, :error_id, error.id))
    else
      add(logs, error.where, :error, error.message)
    end
  end

  @spec log_end(Logs.t()) :: Logs.t()
  def log_end(%Logs{} = logs) do
    logs = add(logs, RitCLI, :info, "end")
    struct(logs, data: Enum.reverse(logs.data))
  end

  @spec log_start :: Logs.t()
  def log_start do
    %Logs{data: [Log.create(RitCLI, :info, "start")]}
  end

  @spec to_map(Logs.t()) :: list(map)
  def to_map(%Logs{} = logs) do
    logs.data
    |> Enum.map(fn log -> Log.to_map(log) end)
  end

  @spec to_string(Logs.t(), keyword) :: String.t()
  def to_string(%Logs{} = logs, opts \\ []) do
    logs.data
    |> Enum.map(fn log -> Log.to_string(log, opts) end)
    |> Enum.join()
  end
end

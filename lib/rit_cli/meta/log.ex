defmodule RitCLI.Meta.Log do
  @moduledoc false

  alias RitCLI.Meta.{Log, Output}

  @level_trailing 7
  @metadata_pad String.pad_trailing("", @level_trailing + 3)

  @type t :: %Log{
          level: atom,
          message: String.t(),
          metadata: map | nil,
          timestamp: DateTime.t() | nil,
          where: atom
        }

  defstruct level: :info,
            message: "",
            metadata: nil,
            timestamp: nil,
            where: nil

  @spec create(module, atom, String.t(), keyword | map | nil) :: Log.t()
  def create(where, level, message, metadata \\ nil) do
    metadata =
      if is_list(metadata) do
        Map.new(metadata)
      else
        metadata
      end

    %Log{
      level: level,
      message: message,
      metadata: metadata,
      where: where,
      timestamp: DateTime.utc_now()
    }
  end

  @spec to_map(Log.t()) :: map
  def to_map(%Log{} = log) do
    %{
      level: log.level,
      message: Output.interpolate_metadata(log.message, log.metadata),
      message_raw: log.message,
      metadata: log.metadata,
      timestamp: log.timestamp,
      where: log.where
    }
  end

  @spec to_string(Log.t(), keyword) :: String.t()
  def to_string(%Log{level: level, metadata: metadata} = log, _opts) do
    level_with_pad = String.pad_trailing("#{level}", @level_trailing)

    # if Keyword.get(opts, :color?, false) do
    message = """
    [%{#{level}}] %{info}
    #{@metadata_pad}- where: %{info}
    #{@metadata_pad}- when: %{info}
    """

    elements = [
      level_with_pad,
      Output.interpolate_metadata(log.message, metadata),
      log.where,
      log.timestamp
    ]

    message = Output.interpolate_colors(message, elements)

    if metadata do
      Enum.reduce(metadata, message, fn {key, value}, message ->
        message <>
          Output.interpolate_colors("#{@metadata_pad}- %{info}: %{info}\n", [key, value])
      end)
    else
      message
    end

    # else
    #   message = """
    #   [#{level_with_pad}] #{Output.interpolate_metadata(log.message, metadata)}
    #   #{@metadata_pad}- where: #{log.where}
    #   #{@metadata_pad}- when: #{log.timestamp}
    #   """

    #   if metadata do
    #     Enum.reduce(log.metadata, message, fn {key, value}, message ->
    #       message <> "#{@metadata_pad}- #{key}: #{value}\n"
    #     end)
    #   else
    #     message
    #   end
    # end
  end
end

defmodule RitCLI.Meta.Error do
  @moduledoc false

  alias RitCLI.Meta.{Error, Output}

  @type t :: %Error{
          id: atom,
          exit_code: integer,
          message: String.t(),
          metadata: map | nil,
          where: atom
        }

  defstruct id: nil,
            exit_code: 1,
            message: "",
            metadata: nil,
            where: nil

  @spec build(module, atom, String.t(), keyword | map | nil, integer) :: Error.t()
  def build(where, id, message, metadata \\ nil, exit_code \\ 1) do
    metadata =
      if is_list(metadata) do
        Map.new(metadata)
      else
        metadata
      end

    %Error{id: id, exit_code: exit_code, message: message, metadata: metadata, where: where}
  end

  @spec to_map(Error.t()) :: map
  def to_map(%Error{} = error) do
    %{
      exit_code: error.exit_code,
      id: error.id,
      message: Output.interpolate_metadata(error.message, error.metadata),
      message_raw: error.message,
      metadata: error.metadata,
      where: error.where
    }
  end

  @spec to_string(Error.t(), keyword) :: String.t()
  def to_string(%Error{} = error, _opts) do
    # if Keyword.get(opts, :color?, false) do
    message = "[%{error}] %{focus}: %{info}"

    elements = [
      "error",
      Recase.to_sentence("#{error.id}"),
      Output.interpolate_metadata(error.message, error.metadata)
    ]

    Output.interpolate_colors(message, elements)
    # else
    #   "[error] #{error.id}: #{Output.interpolate_metadata(error.message, error.metadata)}"
    # end
  end
end

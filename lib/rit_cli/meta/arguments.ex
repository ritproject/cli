defmodule RitCLI.Meta.Arguments do
  @moduledoc false

  alias RitCLI.Meta.Arguments

  @type t :: %Arguments{
          index: integer,
          original: list(String.t()),
          original_length: integer,
          to_parse: list(String.t()),
          to_parse_length: integer
        }

  defstruct index: 0,
            original: [],
            original_length: 0,
            to_parse: [],
            to_parse_length: 0

  @spec create(list(String.t())) :: Arguments.t()
  def create(argv) do
    argv_length = length(argv)

    %Arguments{
      original: argv,
      original_length: argv_length,
      to_parse: argv,
      to_parse_length: argv_length
    }
  end

  @spec update(Arguments.t(), integer) :: Arguments.t()
  def update(%Arguments{} = args, args_parsed) do
    struct(
      args,
      index: min(args.index + args_parsed, args.original_length - 1),
      to_parse: Enum.drop(args.to_parse, args_parsed),
      to_parse_length: max(args.to_parse_length - args_parsed, 0)
    )
  end
end

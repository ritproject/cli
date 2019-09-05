defmodule RitCLI.CLI.Input do
  @moduledoc false

  alias RitCLI.CLI.{Input, Output}

  @type t :: %Input{
          argv: list(String.t()),
          context: atom,
          operation: atom,
          module_id: atom,
          original_input: list(String.t())
        }

  defstruct argv: [],
            context: :unknown,
            operation: :unknown,
            module_id: :rit,
            original_input: []

  @context_map %{
    "a" => :auth,
    "auth" => :auth,
    "c" => :config,
    "config" => :config,
    "g" => :git,
    "git" => :git,
    "h" => :help,
    "help" => :help,
    "t" => :tunnel,
    "tunnel" => :tunnel
  }

  @spec create_input_data(list(String.t())) :: {:ok, Input.t()} | {:error, atom, Output.t()}
  def create_input_data([context | argv] = input) do
    case Map.get(@context_map, Recase.to_snake(context)) do
      context when not is_nil(context) ->
        {:ok, %Input{context: context, argv: argv, original_input: input}}

      _nil ->
        {
          :error,
          :unknown_context,
          %Output{
            error: "Unknown context '#{context}'",
            show_module_helper?: true
          }
        }
    end
  end

  def create_input_data([]) do
    {
      :error,
      :no_context_defined,
      %Output{
        error: "No context defined",
        show_module_helper?: true
      }
    }
  end
end

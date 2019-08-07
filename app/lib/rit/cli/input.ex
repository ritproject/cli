defmodule Rit.CLI.Input do
  @moduledoc false

  alias Rit.CLI.Input

  defstruct context: :unknown,
            argv: []

  @context_map %{
    "a" => :auth,
    "auth" => :auth,
    "c" => :config,
    "config" => :config,
    "g" => :git,
    "git" => :git,
    "h" => :help,
    "help" => :help
  }

  def create_input_data([]) do
    {:ok, %Input{}}
  end

  def create_input_data([context | argv]) do
    case Map.get(@context_map, Recase.to_snake(context)) do
      context when not is_nil(context) -> {:ok, %Input{context: context, argv: argv}}
      _nil -> {:error, :unknown_context, context}
    end
  end
end

defmodule RitCLI.Main.ContextParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @type context :: :config | :help | :tunnel | :version

  @valid_contexts %{
    "c" => :config,
    "config" => :config,
    "h" => :help,
    "help" => :help,
    "t" => :tunnel,
    "tunnel" => :tunnel,
    "v" => :version,
    "version" => :version
  }

  @spec parse(String.t()) :: {:ok, context} | {:error, Error.t()}
  def parse(value) do
    context = Map.get(@valid_contexts, Recase.to_snake(value))

    if context != nil do
      {:ok, context}
    else
      {:error, invalid_context_error(value)}
    end
  end

  defp invalid_context_error(invalid_context) do
    Error.build(
      __MODULE__,
      :invalid_context,
      "the context '%{context}' is invalid",
      context: invalid_context
    )
  end
end

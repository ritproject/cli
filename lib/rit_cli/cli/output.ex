defmodule RitCLI.CLI.Output do
  @moduledoc false

  alias RitCLI.CLI.{Helper, Output}

  @type t :: %Output{
          error: String.t(),
          message: String.t(),
          module_id: atom,
          show_module_helper?: boolean,
          code: integer
        }

  defstruct error: "",
            message: "",
            module_id: :rit,
            show_module_helper?: false,
            code: 0

  @spec inform(Output.t()) :: Output.t()
  def inform(%Output{} = output) do
    output
    |> maybe_inform_error()
    |> maybe_inform_message()
    |> maybe_inform_helper_message()
  end

  defp maybe_inform_error(%Output{error: ""} = output) do
    output
  end

  defp maybe_inform_error(%Output{error: error, code: code} = output) do
    IO.puts("Error: #{error}")

    if code != 0 do
      output
    else
      %{output | code: 1}
    end
  end

  defp maybe_inform_message(%Output{message: message} = output) do
    if message != "" do
      IO.puts(message)
    end

    output
  end

  defp maybe_inform_helper_message(%Output{show_module_helper?: false} = output) do
    output
  end

  defp maybe_inform_helper_message(%Output{module_id: module_id} = output) do
    IO.puts(Helper.get_helper_message(module_id))
    output
  end
end

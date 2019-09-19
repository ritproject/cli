defmodule RitCLI.CLI.Output do
  @moduledoc false

  alias RitCLI.CLI.{Helper, Output}

  @type t :: %Output{
          error: String.t(),
          message: String.t() | keyword,
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
    IO.puts(IO.ANSI.red() <> "Error" <> IO.ANSI.reset() <> ": #{error}")

    if code != 0 do
      output
    else
      %{output | code: 1}
    end
  end

  defp maybe_inform_message(%Output{message: message} = output) do
    message =
      case message do
        message when is_list(message) -> decorate_message(message)
        message -> message
      end

    if message != "" do
      IO.puts(message)
    end

    output
  end

  defp decorate_message(message) do
    Enum.reduce(message, "", &decorate_segment/2)
  end

  defp decorate_segment({:s, segment}, message) do
    message <> IO.ANSI.green() <> segment <> IO.ANSI.reset()
  end

  defp maybe_inform_helper_message(%Output{show_module_helper?: false} = output) do
    output
  end

  defp maybe_inform_helper_message(%Output{module_id: module_id} = output) do
    IO.puts(Helper.get_helper_message(module_id))
    output
  end
end

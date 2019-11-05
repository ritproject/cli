defmodule RitCLI.Meta.Output do
  @moduledoc false

  alias RitCLI.Meta.Output

  @type t :: %Output{
          data: map | nil
        }

  defstruct data: nil

  @spec interpolate_colors(String.t(), list(any)) :: String.t()
  def interpolate_colors(message, elements) do
    Enum.reduce(elements, message, fn element, message ->
      String.replace(
        message,
        ~r/%{([a-z]+)}/,
        fn color_tag ->
          color_tag
          |> String.replace_leading("%{", "")
          |> String.replace_trailing("}", "")
          |> String.to_atom()
          |> colorize(element)
        end,
        global: false
      )
    end)
  end

  @spec interpolate_metadata(String.t(), map | nil) :: String.t()
  def interpolate_metadata(message, metadata) do
    if metadata do
      Enum.reduce(metadata, message, fn {key, value}, message ->
        String.replace(message, "%{#{key}}", "#{value}")
      end)
    else
      message
    end
  end

  @spec show(:inspect | :json | :json_ugly | :plain, any) :: :ok
  def show(:inspect, data), do: IO.puts(inspect(data, pretty: true))
  def show(:json, data), do: IO.puts(Jason.encode!(data, pretty: true))
  def show(:json_ugly, data), do: IO.puts(Jason.encode!(data))
  def show(:plain, message), do: IO.puts(message)

  @spec show_plain(String.t()) :: :ok
  def show_plain(message), do: show(:plain, message)

  @spec to_map(Output.t()) :: map
  def to_map(%Output{} = output), do: output.data

  @spec colorize(atom, any) :: String.t()
  def colorize(:error, message), do: colorize_error(message)
  def colorize(:focus, message), do: colorize_focus(message)
  def colorize(:success, message), do: colorize_success(message)
  def colorize(_info, message), do: "#{message}"

  @spec colorize_error(any) :: String.t()
  def colorize_error(message), do: "#{IO.ANSI.light_red()}#{message}#{IO.ANSI.reset()}"

  @spec colorize_focus(any) :: String.t()
  def colorize_focus(message), do: "#{IO.ANSI.yellow()}#{message}#{IO.ANSI.reset()}"

  @spec colorize_success(any) :: String.t()
  def colorize_success(message), do: "#{IO.ANSI.green()}#{message}#{IO.ANSI.reset()}"
end

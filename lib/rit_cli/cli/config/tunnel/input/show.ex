defmodule RitCLI.CLI.Config.Tunnel.Input.Show do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Tunnel.Input.Show
  alias RitCLI.CLI.Config.Tunnel.Operations
  alias RitCLI.CLI.Config.Tunnel.Validator

  @enforce_keys [:name]
  @type t :: %Show{name: String.t()}

  defstruct name: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      ["help" | _argv] ->
        Helper.handle_input(struct(input, argv: []))

      [name] ->
        perform_operation(%Show{name: name})

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Show{} = input) do
    case Validator.validate_name(input) do
      {:ok, %Show{} = input} ->
        case Operations.Show.show_tunnel(input, Config.Tunnel.get_config()) do
          {:ok, message} -> {:ok, %Output{message: message, module_id: :config_tunnel_show}}
          error -> error
        end

      {:error, error} ->
        {
          :error,
          :config_tunnel_show_input_error,
          %Output{
            error: error,
            module_id: :config_tunnel_show
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_tunnel_show_arguments,
      %Output{
        error: "Unknown config tunnel show arguments: '#{arguments}'",
        module_id: :config_tunnel_show,
        show_module_helper?: true
      }
    }
  end
end

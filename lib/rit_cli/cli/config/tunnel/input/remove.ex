defmodule RitCLI.CLI.Config.Tunnel.Input.Remove do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Tunnel.Input.Remove
  alias RitCLI.CLI.Config.Tunnel.Validator

  @enforce_keys [:name]
  @type t :: %Remove{name: String.t()}

  defstruct name: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      ["help" | _argv] ->
        Helper.handle_input(struct(input, argv: []))

      [name] ->
        perform_operation(%Remove{name: name})

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Remove{} = input) do
    with {:ok, %Remove{name: name} = input} <- validate(input),
         {:ok, config} <- Config.Tunnel.remove_tunnel(input),
         :ok <- Config.Tunnel.save_config(config) do
      message = "Tunnel '#{name}' successfully removed"
      {:ok, %Output{message: message, module_id: :config_tunnel_remove}}
    end
  end

  defp validate(%Remove{} = input) do
    case Validator.validate_name(input) do
      {:ok, input} ->
        {:ok, input}

      {:error, error} ->
        {
          :error,
          :config_tunnel_remove_input_error,
          %Output{
            error: error,
            module_id: :config_tunnel_remove
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_tunnel_remove_arguments,
      %Output{
        error: "Unknown config tunnel remove arguments: '#{arguments}'",
        module_id: :config_tunnel_remove,
        show_module_helper?: true
      }
    }
  end
end

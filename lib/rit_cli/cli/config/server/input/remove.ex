defmodule RitCLI.CLI.Config.Server.Input.Remove do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Server.Input.Remove
  alias RitCLI.CLI.Config.Server.Validator

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
         {:ok, config} <- Config.Server.remove_server(input),
         :ok <- Config.Server.save_config(config) do
      message = "Server '#{name}' successfully removed"
      {:ok, %Output{message: message, module_id: :config_server_remove}}
    end
  end

  defp validate(%Remove{} = input) do
    case Validator.validate_name(input) do
      {:ok, input} ->
        {:ok, input}

      {:error, error} ->
        {
          :error,
          :config_server_remove_input_error,
          %Output{
            error: error,
            module_id: :config_server_remove
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_server_remove_arguments,
      %Output{
        error: "Unknown config server remove arguments: '#{arguments}'",
        module_id: :config_server_remove,
        show_module_helper?: true
      }
    }
  end
end

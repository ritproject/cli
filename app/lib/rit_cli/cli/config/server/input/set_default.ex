defmodule RitCLI.CLI.Config.Server.Input.SetDefault do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Server.Input.SetDefault
  alias RitCLI.CLI.Config.Server.Validator

  @enforce_keys [:name]
  @type t :: %SetDefault{
          name: binary(),
          path: binary()
        }

  defstruct name: "",
            path: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      ["help" | _argv] ->
        Helper.handle_input(struct!(input, argv: []))

      [name] ->
        perform_operation(%SetDefault{name: name})

      [name, "--path", path] ->
        perform_operation(%SetDefault{name: name, path: path})

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%SetDefault{} = input) do
    with {:ok, %SetDefault{name: name} = input} <- validate(input),
         {:ok, config} <- Config.Server.set_default_server(input),
         :ok <- Config.Server.save_config(config) do
      message = "Server '#{name}' successfully set as default"
      {:ok, %Output{message: message, module_id: :config_server_set_default}}
    end
  end

  defp validate(%SetDefault{} = input) do
    with {:ok, input} <- Validator.validate_name(input, :name),
         {:ok, input, _optionals} <- Validator.optional(input, :path, &Validator.validate_path/2) do
      {:ok, input}
    else
      {:error, error} ->
        {
          :error,
          :config_server_set_default_input_error,
          %Output{
            error: error,
            module_id: :config_server_set_default
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_server_set_default_arguments,
      %Output{
        error: "Unknown config server set-default arguments: '#{arguments}'",
        module_id: :config_server_set_default,
        show_module_helper?: true
      }
    }
  end
end

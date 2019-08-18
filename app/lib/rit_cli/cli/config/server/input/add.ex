defmodule RitCLI.CLI.Config.Server.Input.Add do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Server.Input.Add
  alias RitCLI.CLI.Config.Server.Validator

  @enforce_keys [:hostname, :name]
  @type t :: %Add{
          hostname: binary(),
          name: binary(),
          port: binary()
        }

  defstruct hostname: "",
            name: "",
            port: "80"

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      ["help" | _argv] ->
        Helper.handle_input(struct!(input, argv: []))

      [name, hostname] ->
        perform_operation(%Add{name: name, hostname: hostname})

      [name, hostname, "--port", port] ->
        perform_operation(%Add{name: name, hostname: hostname, port: port})

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Add{} = input) do
    with {:ok, %Add{name: name} = input} <- validate(input),
         {:ok, config} <- Config.Server.add_server(input),
         :ok <- Config.Server.save_config(config) do
      message = "Server '#{name}' successfully added"
      {:ok, %Output{message: message, module_id: :config_server_add}}
    end
  end

  defp validate(%Add{} = input) do
    with {:ok, input} <- Validator.validate_name(input, :name),
         {:ok, input} <- Validator.validate_hostname(input, :hostname),
         {:ok, input} <- Validator.validate_port(input, :port) do
      {:ok, input}
    else
      {:error, error} ->
        {
          :error,
          :config_server_add_input_error,
          %Output{
            error: error,
            module_id: :config_server_add
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_server_add_arguments,
      %Output{
        error: "Unknown config server add arguments: '#{arguments}'",
        module_id: :config_server_add,
        show_module_helper?: true
      }
    }
  end
end

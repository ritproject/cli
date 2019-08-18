defmodule RitCLI.CLI.Config.Server.Input.Edit do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Server.Input.Edit
  alias RitCLI.CLI.Config.Server.Validator

  @enforce_keys [:current_name]
  @type t :: %Edit{
          current_name: binary(),
          hostname: binary(),
          name: binary(),
          port: binary()
        }

  defstruct current_name: "",
            hostname: "",
            name: "",
            port: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{argv: ["help" | _argv]} = input) do
    Helper.handle_input(struct!(input, argv: []))
  end

  def handle_input(%Input{argv: argv}) do
    case OptionParser.parse(argv, strict: [name: :string, hostname: :string, port: :string]) do
      {parsed, [current_name | _argv], []} ->
        perform_operation(struct!(Edit, [current_name: current_name] ++ parsed))

      _options ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Edit{} = input) do
    with {:ok, %Edit{name: name, current_name: current_name} = input} <-
           validate(input),
         {:ok, config} <- Config.Server.edit_server(input),
         :ok <- Config.Server.save_config(config) do
      message =
        if name != "" and current_name != name do
          "Server '#{name}' (previously named '#{current_name}') successfully updated"
        else
          "Server '#{current_name}' successfully updated"
        end

      {:ok, %Output{message: message, module_id: :config_server_add}}
    end
  end

  defp validate(%Edit{} = input) do
    with {:ok, input} <- Validator.validate_name(input, :current_name),
         {:ok, input, optionals} <- Validator.optional(input, :name, &Validator.validate_name/2),
         {:ok, input, optionals} <-
           Validator.optional(input, :hostname, &Validator.validate_hostname/2, optionals),
         {:ok, input, optionals} <-
           Validator.optional(input, :port, &Validator.validate_port/2, optionals),
         :ok <- Validator.validate_at_least_one_optional(optionals, [:name, :hostname, :port]) do
      {:ok, input}
    else
      {:error, error} ->
        {
          :error,
          :config_server_edit_input_error,
          %Output{
            error: error,
            module_id: :config_server_edit
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_server_edit_arguments,
      %Output{
        error: "Unknown config server edit arguments: '#{arguments}'",
        module_id: :config_server_edit,
        show_module_helper?: true
      }
    }
  end
end

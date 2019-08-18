defmodule RitCLI.CLI.Config.Server.Input.UnsetDefault do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Server.Input.UnsetDefault
  alias RitCLI.CLI.Config.Server.Validator

  @type t :: %UnsetDefault{path: binary()}

  defstruct path: "*"

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      [] ->
        perform_operation(%UnsetDefault{})

      ["--path", path] ->
        perform_operation(%UnsetDefault{path: path})

      ["help" | _argv] ->
        Helper.handle_input(struct!(input, argv: []))

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%UnsetDefault{} = input) do
    with {:ok, %UnsetDefault{path: path} = input} <- validate(input),
         {:ok, config} <- Config.Server.unset_default_server(input),
         :ok <- Config.Server.save_config(config) do
      message =
        if path != "*" do
          "Default server from '#{path}' path successfully unset"
        else
          "Default global server successfully unset"
        end

      {:ok, %Output{message: message, module_id: :config_server_unset_default}}
    end
  end

  defp validate(%UnsetDefault{path: "*"} = input) do
    {:ok, input}
  end

  defp validate(%UnsetDefault{} = input) do
    case Validator.validate_path(input, :path) do
      {:ok, input} ->
        {:ok, input}

      {:error, error} ->
        {
          :error,
          :config_server_unset_default_input_error,
          %Output{
            error: error,
            module_id: :config_server_unset_default
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_server_unset_default_arguments,
      %Output{
        error: "Unknown config server unset_default arguments: '#{arguments}'",
        module_id: :config_server_unset_default,
        show_module_helper?: true
      }
    }
  end
end

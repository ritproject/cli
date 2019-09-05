defmodule RitCLI.CLI.Config.Tunnel.Default.Input.Set do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Tunnel.Default.Input.Set
  alias RitCLI.CLI.Config.Tunnel.Validator

  @enforce_keys [:name]
  @type t :: %Set{
          name: String.t(),
          path: String.t()
        }

  defstruct name: "",
            path: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      ["help" | _argv] ->
        Helper.handle_input(struct(input, argv: []))

      [name] ->
        perform_operation(%Set{name: name})

      [name, "--path", path] ->
        perform_operation(%Set{name: name, path: path})

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Set{} = input) do
    with {:ok, %Set{name: name} = input} <- validate(input),
         {:ok, config} <- Config.Tunnel.set_default_tunnel(input),
         :ok <- Config.Tunnel.save_config(config) do
      message = "Tunnel '#{name}' successfully set as default"
      {:ok, %Output{message: message, module_id: :config_tunnel_default_set}}
    end
  end

  defp validate(%Set{} = input) do
    with {:ok, input} <- Validator.validate_name(input),
         {:ok, input, _optionals} <-
           Input.Validator.optional(input, :path, &Validator.validate_path/2) do
      {:ok, input}
    else
      {:error, error} ->
        {
          :error,
          :config_tunnel_default_set_input_error,
          %Output{
            error: error,
            module_id: :config_tunnel_default_set
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_tunnel_default_set_arguments,
      %Output{
        error: "Unknown config tunnel default set arguments: '#{arguments}'",
        module_id: :config_tunnel_default_set,
        show_module_helper?: true
      }
    }
  end
end

defmodule RitCLI.CLI.Config.Tunnel.Input.Add do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Tunnel.Input.Add
  alias RitCLI.CLI.Config.Tunnel.Validator

  @enforce_keys [:from, :reference]
  @type t :: %Add{
          from: String.t(),
          name: String.t(),
          reference: String.t()
        }

  defstruct from: "",
            name: "",
            reference: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      ["help" | _argv] ->
        Helper.handle_input(struct(input, argv: []))

      [from, reference] ->
        perform_operation(%Add{from: from, reference: reference})

      [from, reference, "--name", name] ->
        perform_operation(%Add{from: from, name: name, reference: reference})

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Add{} = input) do
    with {:ok, %Add{name: name} = input} <- validate(input),
         {:ok, config} <- Config.Tunnel.add_tunnel(input),
         :ok <- Config.Tunnel.save_config(config) do
      message = "Tunnel '#{name}' successfully added"
      {:ok, %Output{message: message, module_id: :config_tunnel_add}}
    end
  end

  defp validate(%Add{} = input) do
    with {:ok, input} <- Validator.validate_from(input),
         {:ok, input} <- Validator.validate_reference(input),
         {:ok, input} <- Validator.validate_name(input) do
      {:ok, input}
    else
      {:error, error} ->
        {
          :error,
          :config_tunnel_add_input_error,
          %Output{
            error: error,
            module_id: :config_tunnel_add
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_tunnel_add_arguments,
      %Output{
        error: "Unknown config tunnel add arguments: '#{arguments}'",
        module_id: :config_tunnel_add,
        show_module_helper?: true
      }
    }
  end
end

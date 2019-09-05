defmodule RitCLI.CLI.Config.Tunnel.Input.Edit do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Tunnel.Input.Edit
  alias RitCLI.CLI.Config.Tunnel.Validator

  @enforce_keys [:current_name]
  @type t :: %Edit{
          current_name: String.t(),
          from: String.t(),
          name: String.t(),
          reference: String.t()
        }

  defstruct current_name: "",
            from: "",
            name: "",
            reference: ""

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: ["help" | _argv]} = input) do
    Helper.handle_input(struct(input, argv: []))
  end

  def handle_input(%Input{argv: argv}) do
    case OptionParser.parse(argv, strict: [from: :string, name: :string, reference: :string]) do
      {parsed, [current_name | _argv], []} ->
        perform_operation(struct(Edit, [current_name: current_name] ++ parsed))

      _options ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Edit{} = input) do
    with {:ok, %Edit{name: name, current_name: current_name} = input} <-
           validate(input),
         {:ok, config} <- Config.Tunnel.edit_tunnel(input),
         :ok <- Config.Tunnel.save_config(config) do
      message =
        if name != "" and current_name != name do
          "Tunnel '#{name}' (previously named '#{current_name}') successfully updated"
        else
          "Tunnel '#{current_name}' successfully updated"
        end

      {:ok, %Output{message: message, module_id: :config_tunnel_edit}}
    end
  end

  defp validate(%Edit{} = input) do
    with {:ok, input} <- Validator.validate_name(input, :current_name),
         {:ok, input, optionals} <-
           Input.Validator.optional(input, :from, &Validator.validate_from/2),
         {:ok, input, optionals} <-
           Input.Validator.optional(input, :reference, &Validator.validate_reference/2, optionals),
         {:ok, input, optionals} <-
           Input.Validator.optional(input, :name, &Validator.validate_name/2, optionals),
         :ok <- Input.Validator.validate_at_least_one_optional(optionals, [:from, :name, :reference]) do
      {:ok, input}
    else
      {:error, error} ->
        {
          :error,
          :config_tunnel_edit_input_error,
          %Output{
            error: error,
            module_id: :config_tunnel_edit
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_tunnel_edit_arguments,
      %Output{
        error: "Unknown config tunnel edit arguments: '#{arguments}'",
        module_id: :config_tunnel_edit,
        show_module_helper?: true
      }
    }
  end
end

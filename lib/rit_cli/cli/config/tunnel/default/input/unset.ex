defmodule RitCLI.CLI.Config.Tunnel.Default.Input.Unset do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Tunnel.Default.Input.Unset
  alias RitCLI.CLI.Config.Tunnel.Validator

  @type t :: %Unset{path: String.t()}

  defstruct path: "*"

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      [] ->
        perform_operation(%Unset{})

      ["--path", path] ->
        perform_operation(%Unset{path: path})

      ["help" | _argv] ->
        Helper.handle_input(struct(input, argv: []))

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation(%Unset{} = input) do
    with {:ok, %Unset{path: path} = input} <- validate(input),
         {:ok, config} <- Config.Tunnel.unset_default_tunnel(input),
         :ok <- Config.Tunnel.save_config(config) do
      message =
        if path != "*" do
          "Default tunnel from '#{path}' path successfully unset"
        else
          "Default global tunnel successfully unset"
        end

      {:ok, %Output{message: message, module_id: :config_tunnel_default_unset}}
    end
  end

  defp validate(%Unset{path: "*"} = input) do
    {:ok, input}
  end

  defp validate(%Unset{} = input) do
    case Validator.validate_path(input) do
      {:ok, input} ->
        {:ok, input}

      {:error, error} ->
        {
          :error,
          :config_tunnel_default_unset_input_error,
          %Output{
            error: error,
            module_id: :config_tunnel_default_unset
          }
        }
    end
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_tunnel_default_unset_arguments,
      %Output{
        error: "Unknown config tunnel default unset arguments: '#{arguments}'",
        module_id: :config_tunnel_default_unset,
        show_module_helper?: true
      }
    }
  end
end

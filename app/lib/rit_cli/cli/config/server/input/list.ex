defmodule RitCLI.CLI.Config.Server.Input.List do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}
  alias RitCLI.CLI.Config.Server.Operations

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{argv: argv} = input) do
    case argv do
      [] ->
        perform_operation()

      ["help" | _argv] ->
        Helper.handle_input(struct!(input, argv: []))

      argv ->
        arguments_error(argv)
    end
  end

  defp perform_operation do
    {
      :ok,
      %Output{
        message: Operations.List.list_servers(Config.Server.get_config()),
        module_id: :config_server_list
      }
    }
  end

  defp arguments_error(argv) do
    arguments = Enum.join(argv, " ")

    {
      :error,
      :unknown_config_server_list_arguments,
      %Output{
        error: "Unknown config server list arguments: '#{arguments}'",
        module_id: :config_server_list,
        show_module_helper?: true
      }
    }
  end
end

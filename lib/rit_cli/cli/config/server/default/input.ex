defmodule RitCLI.CLI.Config.Server.Default.Input do
  @moduledoc false

  alias RitCLI.CLI.{Helper, Input, Output}

  alias RitCLI.CLI.Config.Server.Default.Input.{Set, Unset}

  @operations_map %{
    "h" => :help,
    "help" => :help,
    "s" => :set,
    "set" => :set,
    "u" => :unset,
    "unset" => :unset
  }

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: [operation | argv]} = input) do
    case Map.get(@operations_map, Recase.to_snake(operation)) do
      operation when not is_nil(operation) ->
        redirect_to_operation(struct(input, operation: operation, argv: argv))

      _nil ->
        {
          :error,
          :unknown_config_server_default_operation,
          %Output{
            error: "Unknown config server default operation '#{operation}'",
            module_id: :config_server_default,
            show_module_helper?: true
          }
        }
    end
  end

  def handle_input(%Input{argv: []}) do
    {
      :error,
      :no_config_server_default_operation_defined,
      %Output{
        error: "No config server default operation defined",
        module_id: :config_server_default,
        show_module_helper?: true
      }
    }
  end

  defp redirect_to_operation(%Input{operation: operation} = input) do
    case operation do
      :help -> Helper.handle_input(input)
      :set -> Set.handle_input(struct(input, module_id: :config_server_default_set))
      :unset -> Unset.handle_input(struct(input, module_id: :config_server_default_unset))
    end
  end
end

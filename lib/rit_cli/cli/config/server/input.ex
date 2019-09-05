defmodule RitCLI.CLI.Config.Server.Input do
  @moduledoc false

  alias RitCLI.CLI.{Helper, Input, Output}

  alias RitCLI.CLI.Config.Server.Default

  alias RitCLI.CLI.Config.Server.Input.{
    Add,
    Edit,
    List,
    Remove,
    Show
  }

  @operations_map %{
    "a" => :add,
    "add" => :add,
    "d" => :default,
    "default" => :default,
    "e" => :edit,
    "edit" => :edit,
    "h" => :help,
    "help" => :help,
    "l" => :list,
    "list" => :list,
    "r" => :remove,
    "remove" => :remove,
    "s" => :show,
    "show" => :show
  }

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: [operation | argv]} = input) do
    case Map.get(@operations_map, Recase.to_snake(operation)) do
      operation when not is_nil(operation) ->
        redirect_to_operation(struct(input, operation: operation, argv: argv))

      _nil ->
        {
          :error,
          :unknown_config_server_operation,
          %Output{
            error: "Unknown config server operation '#{operation}'",
            module_id: :config_server,
            show_module_helper?: true
          }
        }
    end
  end

  def handle_input(%Input{argv: []}) do
    {
      :error,
      :no_config_server_operation_defined,
      %Output{
        error: "No config server operation defined",
        module_id: :config_server,
        show_module_helper?: true
      }
    }
  end

  defp redirect_to_operation(%Input{operation: operation} = input) do
    case operation do
      :add ->
        Add.handle_input(struct(input, module_id: :config_server_add))

      :default ->
        Default.handle_input(struct(input, module_id: :config_server_default))

      :edit ->
        Edit.handle_input(struct(input, module_id: :config_server_edit))

      :help ->
        Helper.handle_input(input)

      :list ->
        List.handle_input(struct(input, module_id: :config_server_list))

      :remove ->
        Remove.handle_input(struct(input, module_id: :config_server_remove))

      :show ->
        Show.handle_input(struct(input, module_id: :config_server_show))
    end
  end
end

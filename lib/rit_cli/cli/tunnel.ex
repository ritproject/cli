defmodule RitCLI.CLI.Tunnel do
  @moduledoc false

  alias RitCLI.CLI.{Helper, Input, Output}
  alias RitCLI.CLI.Tunnel

  @context_map %{
    "h" => :help,
    "help" => :help,
    "r" => :run,
    "run" => :run
  }

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: [context | argv]} = input) do
    case Map.get(@context_map, Recase.to_snake(context)) do
      context when not is_nil(context) ->
        redirect_to_context(struct(input, context: context, argv: argv))

      _nil ->
        {
          :error,
          :unknown_tunnel_context,
          %Output{
            error: "Unknown tunnel context '#{context}'",
            module_id: :tunnel,
            show_module_helper?: true
          }
        }
    end
  end

  def handle_input(%Input{argv: []}) do
    {
      :error,
      :no_tunnel_context_defined,
      %Output{
        error: "No tunnel context defined",
        module_id: :tunnel,
        show_module_helper?: true
      }
    }
  end

  defp redirect_to_context(%Input{context: context} = input) do
    case context do
      :help -> Helper.handle_input(input)
      :run -> Tunnel.Run.handle_input(struct(input, module_id: :tunnel_run))
    end
  end
end

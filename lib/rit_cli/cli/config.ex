defmodule RitCLI.CLI.Config do
  @moduledoc false

  alias RitCLI.CLI.{Config, Helper, Input, Output}

  @context_map %{
    "h" => :help,
    "help" => :help,
    "s" => :server,
    "server" => :server,
    "servers" => :server,
    "t" => :tunnel,
    "tunnel" => :tunnel,
    "tunnels" => :tunnel
  }

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{argv: [context | argv]} = input) do
    case Map.get(@context_map, Recase.to_snake(context)) do
      context when not is_nil(context) ->
        redirect_to_context(struct(input, context: context, argv: argv))

      _nil ->
        {
          :error,
          :unknown_config_context,
          %Output{
            error: "Unknown config context '#{context}'",
            module_id: :config,
            show_module_helper?: true
          }
        }
    end
  end

  def handle_input(%Input{argv: []}) do
    {
      :error,
      :no_config_context_defined,
      %Output{
        error: "No config context defined",
        module_id: :config,
        show_module_helper?: true
      }
    }
  end

  defp redirect_to_context(%Input{context: context} = input) do
    case context do
      :server -> Config.Server.handle_input(struct(input, module_id: :config_server))
      :tunnel -> Config.Tunnel.handle_input(struct(input, module_id: :config_tunnel))
      :help -> Helper.handle_input(input)
    end
  end
end

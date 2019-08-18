defmodule RitCLI.CLI.Helper do
  @moduledoc false

  alias RitCLI.CLI
  alias RitCLI.CLI.{Input, Output}

  @rit_message """
  usage: rit <context> [arguments]

  Perform operations that improve your development and requirements management.

  Available contexts:
    a, auth      Perform authentication operations to a RitServer
    c, config    Configuration operations
    h, help      Guidance about rit usage
    g, git       Use your 'git' command
  """

  @config_message """
  usage: rit config <context> [arguments]

  Perform operations on your rit configuration files.

  Available config contexts:
    h, help               Guidance about rit config usage
    s, server, servers    Manage your server integration configuration
  """

  @config_server_message """
  usage: rit config server <operation> [arguments]

  Manage your server integration configuration.

  Available operations:
    a, add               Add a new server to your configurations
    e, edit              Change the info of a server in your configurations
    h, help              Guidance about rit config server usage
    l, list              Show all servers configured on your machine
    r, remove            Remove a server from your configurations
    s, show              Show a server from your configurations
    sd, set-default      Set a server as your default server
    ud, unset-default    Unset a default server from a path
  """

  @config_server_add_message """
  usage: rit config server add <server_name>
                               <server_hostname>
                               --port <server_port>

  Add a new server to your configurations.

  Arguments:
    <server_name>        A name for the new server
    <server_hostname>    A valid access link to the server

  Option:
    --port               The port of the server, defaults to 80
  """

  @config_server_edit_message """
  usage: rit config server edit <server_current_name>
                                --name <server_name>
                                --hostname <server_hostname>
                                --port <server_port>

  Change the info of a server in your configurations.

  Argument:
    <server_name>    Name of the server

  Options (at least one must be defined):
    --name           Update server name
    --hostname       Update server hostname
    --port           Update server port
  """

  @config_server_list_message """
  usage: rit config server list

  Show all servers configured on your machine.
  """

  @config_server_remove_message """
  usage: rit config server remove <server_name>

  Remove a server from your configurations.

  Argument:
    <server_name>    Name of the server
  """

  @config_server_show_message """
  usage: rit config server show <server_name>

  Show a server from your configurations.

  Arguments:
    <server_name>    Name of the server
  """

  @config_server_set_default_message """
  usage: rit config server set-default <server_name>
                                       --path <path>

  Set a server as your default server.

  Arguments:
    <server_name>    Name of the server

  Option:
    --path    Path where the default server will be set. If blank, the server
              will be interpreted as global default
  """

  @config_server_unset_default_server """
  usage: rit config server unset-default --path <path>

  Unset a default server.

  Option:
    --path    Path where the default server was set. If blank, unset global
  """

  @messages %{
    help: @rit_message,
    rit: @rit_message,
    config: @config_message,
    config_server: @config_server_message,
    config_server_list: @config_server_list_message,
    config_server_show: @config_server_show_message,
    config_server_add: @config_server_add_message,
    config_server_edit: @config_server_edit_message,
    config_server_remove: @config_server_remove_message,
    config_server_set_default: @config_server_set_default_message,
    config_server_unset_default: @config_server_unset_default_server
  }

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{module_id: module_id, argv: argv, original_input: original_input}) do
    if Enum.empty?(argv) do
      {:ok, %Output{module_id: module_id, show_module_helper?: true}}
    else
      [_context | input] = original_input
      CLI.handle_input(input ++ ["help"])
    end
  end

  @spec get_helper_message(atom()) :: binary()
  def get_helper_message(module_id) do
    Map.get(@messages, module_id, "")
  end
end

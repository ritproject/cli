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
    t, tunnel    Bind utility for directories and repos
  """

  @config_message """
  usage: rit config <context> [arguments]

  Perform operations on your rit configuration files.

  Available config contexts:
    h, help               Guidance about rit config usage
    s, server, servers    Manage your server integration configuration
    t, tunnel, tunnels    Manage your tunnel configuration
  """

  @config_server_message """
  usage: rit config server <operation> [arguments]

  Manage your server integration configuration.

  Available operations:
    a, add               Add a new server to your configurations
    d, default           Manage default server configuration
    e, edit              Change the info of a server in your configurations
    h, help              Guidance about rit config server usage
    l, list              Show all servers configured on your machine
    r, remove            Remove a server from your configurations
    s, show              Show a server from your configurations
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

  @config_server_default_message """
  usage: rit config server default <operation> [arguments]

  Manage default server configuration.

  Available operations:
    s, set      Set a server as your default server
    u, unset    Unset a default server from a path
  """

  @config_server_default_set_message """
  usage: rit config server default set <server_name>
                                       --path <path>

  Set a server as your default server.

  Arguments:
    <server_name>    Name of the server

  Option:
    --path    Path where the default server will be set. If blank, the server
              will be interpreted as global default
  """

  @config_server_default_unset_message """
  usage: rit config server default unset --path <path>

  Unset a default server.

  Option:
    --path    Path where the default server was set. If blank, unset global
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

  @config_tunnel_message """
  usage: rit config tunnel <operation> [arguments]

  Manage your tunnel configuration.

  Available operations:
    a, add               Add a new tunnel to your configurations
    d, default           Manage default tunnel configuration
    e, edit              Change the info of a tunnel in your configurations
    h, help              Guidance about rit config tunnel usage
    l, list              Show all tunnels configured on your machine
    r, remove            Remove a tunnel from your configurations
    s, show              Show a tunnel from your configurations
  """

  @config_tunnel_add_message """
  usage: rit config tunnel add <tunnel_from>
                               <tunnel_reference>
                               --name <tunnel_name>

  Add a new tunnel to your configurations.

  Arguments:
    <tunnel_from>         Origin of the tunnel source
                          Options:
                            repo:  From a git remote repository
                                   Reference must be an URL
                            local: From a local directory
                                   Reference must be a valid path
    <tunnel_reference>    A valid reference for the source

  Option:
    --name                A name for the new tunnel, defaults to the last
                          segment of <tunnel_reference>
  """

  @config_tunnel_default_message """
  usage: rit config tunnel default <operation> [arguments]

  Manage default tunnel configuration.

  Available operations:
    s, set      Set a tunnel as your default tunnel
    u, unset    Unset a default tunnel from a path
  """

  @config_tunnel_default_set_message """
  usage: rit config tunnel default set <tunnel_name>
                                       --path <path>

  Set a tunnel as your default tunnel.

  Arguments:
    <tunnel_name>    Name of the tunnel

  Option:
    --path    Path where the default tunnel will be set. If blank, the tunnel
              will be interpreted as global default
  """

  @config_tunnel_default_unset_message """
  usage: rit config tunnel default unset --path <path>

  Unset a default tunnel.

  Option:
    --path    Path where the default tunnel was set. If blank, unset global
  """

  @config_tunnel_edit_message """
  usage: rit config tunnel edit <tunnel_current_name>
                                --name <tunnel_name>
                                --from <tunnel_from>
                                --reference <tunnel_reference>

  Change the info of a tunnel in your configurations.

  Argument:
    <tunnel_name>    Name of the tunnel

  Options (at least one must be defined):
    --name           Update tunnel name
    --from           Update tunnel origin source
    --reference      Update tunnel reference
  """

  @config_tunnel_list_message """
  usage: rit config tunnel list

  Show all tunnels configured on your machine.
  """

  @config_tunnel_remove_message """
  usage: rit config tunnel remove <tunnel_name>

  Remove a tunnel from your configurations.

  Argument:
    <tunnel_name>    Name of the tunnel
  """

  @config_tunnel_show_message """
  usage: rit config tunnel show <tunnel_name>

  Show a tunnel from your configurations.

  Arguments:
    <tunnel_name>    Name of the tunnel
  """

  @tunnel_message """
  usage: rit tunnel <context> [arguments]

  Bind external directory into current directory and perform operations

  Available contexts:
    h, help    Guidance about rit usage
    r, run     Run operation defined on default tunnel config directory
  """

  @messages %{
    help: @rit_message,
    rit: @rit_message,
    config: @config_message,
    config_server: @config_server_message,
    config_server_add: @config_server_add_message,
    config_server_default: @config_server_default_message,
    config_server_default_set: @config_server_default_set_message,
    config_server_default_unset: @config_server_default_unset_message,
    config_server_edit: @config_server_edit_message,
    config_server_list: @config_server_list_message,
    config_server_remove: @config_server_remove_message,
    config_server_show: @config_server_show_message,
    config_tunnel: @config_tunnel_message,
    config_tunnel_add: @config_tunnel_add_message,
    config_tunnel_default: @config_tunnel_default_message,
    config_tunnel_default_set: @config_tunnel_default_set_message,
    config_tunnel_default_unset: @config_tunnel_default_unset_message,
    config_tunnel_edit: @config_tunnel_edit_message,
    config_tunnel_list: @config_tunnel_list_message,
    config_tunnel_remove: @config_tunnel_remove_message,
    config_tunnel_show: @config_tunnel_show_message,
    tunnel: @tunnel_message
  }

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
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

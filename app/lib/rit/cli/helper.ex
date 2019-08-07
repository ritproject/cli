defmodule Rit.CLI.Helper do
  @moduledoc false

  alias Rit.CLI.{Input, Output}

  @message """
  usage: rit <context> [arguments]

  Available contexts:
    a, auth      Perform authentication operations to a RitServer
    c, config    Configuration operations
    g, git       Use your 'git' command
  """

  def handle_input(%Input{context: context}) do
    Output.inform @message
    if context == :help, do: 0, else: 1
  end

  @config_helper %{
    "default" => """
    usage: rit config <operation> [arguments]

    Perform operations on your rit configuration files.

    Available operations:

      =======
      Servers
      =======

      list-servers            Show all servers configured on your machine

      show-server             Show a server from your configurations

      add-server              Add a new server to your configurations
      edit-server             Change the info of a server in your configurations
      remove-server           Remove a server from your configurations

      set-default-server      Set a server as your default server
      unset-default-server    Unset a default server from a path
    """,
    "list-servers" => """
    usage: rit config list-servers

    Show all servers configured on your machine.
    """,
    "show-server" => """
    usage: rit config show-server <server_name>

    Show a server from your configurations.

    Arguments:
      <server_name>    Name of the server
    """,
    "add-server" => """
    usage: rit config add-server <server_name> <server_hostname> <server_port>

    Add a new server to your configurations.

    Arguments:
      <server_name>        A name for the new server
      <server_hostname>    A valid access link to the server
      <server_port>        The port of the server, can be blank, default: 80
    """,
    "edit-server" => """
    usage: rit config edit-server <server_current_name>
              --name <server_name>
              --hostname <server_hostname>
              --port <server_port>

    Change the info of a server in your configurations

    Argument:
      <server_name>    Name of the server

    Options:
      --name        Update server name
      --hostname    Update server hostname
      --port        Update server port
    """,
    "remove-server" => """
    usage: rit config remove-server <server_name>

    Remove a server from your configurations.

    Argument:
      <server_name>    Name of the server
    """,
    "set-default-server" => """
    usage: rit config set-default-server <server_name> --path <path>

    Set a server as your default server.

    Arguments:
      <server_name>    Name of the server

    Option:
      --path    Path where the default server will be set, can be blank, default: global
    """,
    "unset-default-server" => """
    usage: rit config unset-default-server <path>

    Unset a default server from a path.

    Arguments:
      <path>    Path where the default server was set, can be blank, default: unset global
    """
  }

  def show_config_helper(operation \\ "default") do
    if Map.has_key? @config_helper, operation do
      Output.inform @config_helper[operation]
      0
    else
      Output.inform {:error, :invalid_operation, operation}
      Output.inform @config_helper["default"]
      1
    end
  end
end

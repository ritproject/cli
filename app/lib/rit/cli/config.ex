defmodule Rit.CLI.Config do
  @moduledoc false

  alias Rit.CLI.{Config, Helper, Input, Output}

  @help "help"
  @list_servers "list-servers"
  @show_server "show-server"
  @add_server "add-server"
  @edit_server "edit-server"
  @remove_server "remove-server"
  @set_default_server "set-default-server"
  @unset_default_server "unset-default-server"

  def handle_input(%Input{argv: []}) do
    Helper.show_config_helper()
    1
  end

  def handle_input(%Input{argv: [@help | argv]}) do
    case argv do
      [operation | _argv] -> Helper.show_config_helper operation
      _argv -> Helper.show_config_helper()
    end
  end

  def handle_input(%Input{argv: [@list_servers | argv]}) do
    case argv do
      ["help" | _argv] -> Helper.show_config_helper @list_servers
      [] -> list_servers()
      _argv ->
        Helper.show_config_helper @list_servers
        1
    end
  end

  def handle_input(%Input{argv: [@show_server | argv]}) do
    case argv do
      ["help" | _argv] -> Helper.show_config_helper @show_server
      [name] -> show_server %{name: name}
      _argv ->
        Helper.show_config_helper @show_server
        1
    end
  end

  def handle_input(%Input{argv: [@add_server | argv]}) do
    case argv do
      ["help" | _argv] -> Helper.show_config_helper @add_server
      [name, hostname] -> add_server %{name: name, hostname: hostname, port: "80"}
      [name, hostname, port] -> add_server %{name: name, hostname: hostname, port: port}
      _argv ->
        Helper.show_config_helper @add_server
        1
    end
  end

  def handle_input(%Input{argv: [@edit_server | ["help" | _argv]]}) do
    Helper.show_config_helper @edit_server
  end

  @edit_server_strict_list name: :string, hostname: :string, port: :string

  def handle_input(%Input{argv: [@edit_server | argv]}) do
    case OptionParser.parse(argv, strict: @edit_server_strict_list) do
      {parsed, [current_name | _argv], []} ->
        edit_server Map.put(Enum.into(parsed, %{}), :current_name, current_name)
      _options ->
        Helper.show_config_helper @add_server
        1
    end
  end

  def handle_input(%Input{argv: [@remove_server | argv]}) do
    case argv do
      ["help" | _argv] -> Helper.show_config_helper @remove_server
      [name] -> remove_server %{name: name}
      _argv ->
        Helper.show_config_helper @remove_server
        1
    end
  end

  def handle_input(%Input{argv: [@set_default_server | argv]}) do
    case argv do
      ["help" | _argv] -> Helper.show_config_helper @set_default_server
      [name] -> set_default_server %{name: name, path: nil}
      [name, "--path", path] -> set_default_server %{name: name, path: path}
      _argv ->
        Helper.show_config_helper @set_default_server
        1
    end
  end

  def handle_input(%Input{argv: [@unset_default_server | argv]}) do
    case argv do
      [] -> unset_default_server %{path: nil}
      ["help" | _argv] -> Helper.show_config_helper @unset_default_server
      [path] -> unset_default_server %{path: path}
      _argv ->
        Helper.show_config_helper @unset_default_server
        1
    end
  end

  def handle_input(%Input{argv: [operation | _argv]}) do
    Helper.show_config_helper operation
  end

  defp list_servers do
    case Config.Server.get(:list_servers) do
      :ok ->
        0

      error ->
        Output.inform error
        1
    end
  end

  defp show_server(input) do
    with {:ok, data} <- Config.ServerValidator.validate(input, :show_server),
         :ok <- Config.Server.get(data, :show_server) do
      0
    else
      error ->
        Output.inform error
        1
    end
  end

  defp add_server(input) do
    with {:ok, %{name: name} = data} <- Config.ServerValidator.validate(input, :add_server),
         {:ok, _config} <- Config.Server.update(data, :add_server) do
      Output.inform "Server '#{name}' successfully added."
    else
      error ->
        Output.inform error
        1
    end
  end

  def edit_server(input) do
    with {:ok, data} <- Config.ServerValidator.validate(input, :edit_server),
         {:ok, _config} <- Config.Server.update(data, :edit_server) do
      %{current_name: current_name, name: name} = data

      if current_name != name do
        Output.inform "Server '#{name}' (previously named '#{current_name}') successfully updated."
      else
        Output.inform "Server '#{name}' successfully updated."
      end
    else
      error ->
        Output.inform error
        1
    end
  end

  def remove_server(input) do
    with {:ok, %{name: name} = data} <- Config.ServerValidator.validate(input, :remove_server),
         {:ok, _config} <- Config.Server.update(data, :remove_server) do
      Output.inform "Server '#{name}' successfully removed."
    else
      error ->
        Output.inform error
        1
    end
  end

  defp set_default_server(input) do
    with {:ok, %{name: name} = data} <- Config.ServerValidator.validate(input, :set_default_server),
         {:ok, _config} <- Config.Server.update(data, :set_default_server) do
      Output.inform "Server '#{name}' successfully set as default."
    else
      error ->
        Output.inform error
        1
    end
  end

  defp unset_default_server(input) do
    with {:ok, %{path: path} = data} <- Config.ServerValidator.validate(input, :unset_default_server),
         {:ok, _config} <- Config.Server.update(data, :unset_default_server) do
      if path do
        Output.inform "Default server from '#{path}' path successfully unset."
      else
        Output.inform "Default global server sucessfully unset."
      end
    else
      error ->
        Output.inform error
        1
    end
  end
end

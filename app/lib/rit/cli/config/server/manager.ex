defmodule Rit.CLI.Config.ServerManager do
  @moduledoc false

  alias Rit.CLI.Config.ServerManager

  @derive Jason.Encoder
  defstruct servers: %{}, defaults: %{}

  def list_servers(config) do
    %{servers: servers, defaults: defaults} = Map.merge %ServerManager{}, config

    if Enum.empty? servers do
      IO.puts "There are no servers configured on your machine."
    else
      IO.puts """

      # Servers
      """

      Enum.each servers, fn {name, %{hostname: hostname, port: port}} ->
        IO.puts "- #{to_string name}: #{hostname}:#{port}"
      end

      unless Enum.empty? defaults do
        IO.puts """

        ## Default Paths
        """

        Enum.each defaults, fn {path, server_name} ->
          path = if path == :*, do: "(global)", else: path
          IO.puts "- #{path}: #{server_name}"
        end
      end
    end
  end

  def show_server(config, %{name: name}) do
    %{servers: servers, defaults: defaults} = Map.merge %ServerManager{}, config

    if Map.has_key? servers, name do
      %{hostname: hostname, port: port} = Map.get servers, name

      name = to_string name

      IO.puts "- #{name}: #{hostname}:#{port}"

      if Enum.empty? defaults do
        :ok
      else
        Enum.each defaults, fn {path, server_name} ->
          if server_name == name do
            path = if path == :*, do: "(global)", else: path
            IO.puts "  #{path}"
          end
        end
      end
    else
      {:error, :input_error, name, "Server not found."}
    end
  end

  def add_server(config, %{name: name, hostname: hostname, port: port}) do
    config = Map.merge %ServerManager{}, config

    if Map.has_key? config.servers, name do
      {:error, :input_error, name, "Server already exists."}
    else
      server = %{hostname: hostname, port: port}
      {:ok, Map.put(config, :servers, Map.put(config.servers, name, server))}
    end
  end

  def edit_server(config, data) do
    config = Map.merge %ServerManager{}, config
    {current_name, data} = Map.pop data, :current_name

    if Map.has_key? config.servers, current_name do
      {current_server, servers} = Map.pop config.servers, current_name

      if Map.has_key? data, :name do
        {name, data} = Map.pop data, :name
        server = Map.merge current_server, data

        current_name = to_string current_name

        config =
          if Enum.empty? config.defaults do
            config
          else
            defaults = Enum.reduce config.defaults, %{}, fn {path, path_server_name}, map ->
              if path_server_name == current_name do
                Map.put(map, path, name)
              else
                Map.put(map, path, path_server_name)
              end
            end
            Map.put(config, :defaults, defaults)
          end

        {:ok, Map.put(config, :servers, Map.put(servers, name, server))}
      else
        server = Map.merge current_server, data
        {:ok, Map.put(config, :server, Map.put(servers, current_name, server))}
      end
    else
      {:error, :input_error, current_name, "Server not found."}
    end
  end

  def remove_server(config, %{name: name}) do
    config = Map.merge %ServerManager{}, config

    if Map.has_key? config.servers, name do
      servers = Map.drop config.servers, [name]

      name = to_string name

      defaults = Enum.reduce config.defaults, %{}, fn {path, path_server_name}, map ->
        if path_server_name == name do
          map
        else
          Map.put(map, path, path_server_name)
        end
      end
      {:ok, %ServerManager{config | servers: servers, defaults: defaults}}
    else
      {:error, :input_error, name, "Server not found."}
    end
  end

  def set_default_server(config, %{name: name, path: path}) do
    config = Map.merge(%ServerManager{}, config)

    if Map.has_key? config.servers, name do
      defaults =
        if path != nil do
          Map.put(config.defaults, path, name)
        else
          Map.put(config.defaults, :*, name)
        end

      {:ok, Map.put(config, :defaults, defaults)}
    else
      {:error, :input_error, name, "Server not found."}
    end
  end

  def unset_default_server(config, %{path: path}) do
    config = Map.merge %ServerManager{}, config

    if path do
      if Map.has_key? config.defaults, path do
        {:ok, Map.put(config, :defaults, Map.drop(config.defaults, [path]))}
      else
        {:error, :input_error, path, "There are no default servers set on path."}
      end
    else
      if Map.has_key? config.defaults, :* do
        {:ok, Map.put(config, :defaults, Map.drop(config.defaults, [:*]))}
      else
        {:error, :input_error, "There are no global default server set."}
      end
    end
  end
end

defmodule RitCLI.CLI.Config.Server do
  @moduledoc false

  alias RitCLI.CLI.{Config, Input, Output}
  alias RitCLI.CLI.Config.Server

  @type t :: %Server{
          defaults: map(),
          servers: map()
        }

  @derive Jason.Encoder
  defstruct defaults: %{},
            servers: %{}

  @context "server"

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom(), Output.t()}
  def handle_input(%Input{} = input) do
    Server.Input.handle_input(input)
  end

  @spec get_config :: Server.t()
  def get_config do
    struct!(Server, Config.Manager.get_config(@context))
  rescue
    _error -> %Server{}
  end

  @spec clear_config :: :ok | {:error, atom}
  def clear_config do
    Config.Manager.clear_config(@context)
  end

  @spec save_config(Server.t()) :: :ok
  def save_config(%Server{} = config) do
    Config.Manager.save_config(@context, config)
  end

  @spec has_server?(binary()) :: boolean
  def has_server?(name) do
    has_server?(name, get_config())
  end

  @spec has_server?(any, Server.t()) :: boolean
  def has_server?(name, %Server{servers: servers}) do
    Map.has_key?(servers, String.to_atom(name))
  end

  @spec add_server(Server.Input.Add.t()) :: {:ok, Server.t()} | {:error, atom(), Output.t()}
  def add_server(%Server.Input.Add{} = input) do
    add_server(input, get_config())
  end

  @spec add_server(Server.Input.Add.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def add_server(%Server.Input.Add{} = input, %Server{} = config) do
    Server.Operations.add_server(input, config)
  end

  @spec edit_server(Server.Input.Edit.t()) :: {:ok, Server.t()} | {:error, atom(), Output.t()}
  def edit_server(%Server.Input.Edit{} = input) do
    edit_server(input, get_config())
  end

  @spec edit_server(Server.Input.Edit.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def edit_server(%Server.Input.Edit{} = input, %Server{} = config) do
    Server.Operations.edit_server(input, config)
  end

  @spec remove_server(Server.Input.Remove.t()) :: {:ok, Server.t()} | {:error, atom(), Output.t()}
  def remove_server(%Server.Input.Remove{} = input) do
    remove_server(input, get_config())
  end

  @spec remove_server(Server.Input.Remove.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def remove_server(%Server.Input.Remove{} = input, %Server{} = config) do
    Server.Operations.remove_server(input, config)
  end

  @spec set_default_server(Server.Input.SetDefault.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def set_default_server(%Server.Input.SetDefault{} = input) do
    set_default_server(input, get_config())
  end

  @spec set_default_server(Server.Input.SetDefault.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def set_default_server(%Server.Input.SetDefault{} = input, %Server{} = config) do
    Server.Operations.set_default_server(input, config)
  end

  @spec unset_default_server(Server.Input.UnsetDefault.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def unset_default_server(%Server.Input.UnsetDefault{} = input) do
    unset_default_server(input, get_config())
  end

  @spec unset_default_server(Server.Input.UnsetDefault.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, atom(), Output.t()}
  def unset_default_server(%Server.Input.UnsetDefault{} = input, %Server{} = config) do
    Server.Operations.unset_default_server(input, config)
  end
end

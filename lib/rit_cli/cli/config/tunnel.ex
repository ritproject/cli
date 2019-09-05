defmodule RitCLI.CLI.Config.Tunnel do
  @moduledoc false

  alias RitCLI.CLI.{Config, Input, Output}
  alias RitCLI.CLI.Config.Tunnel

  @type t :: %Tunnel{
          defaults: map,
          tunnels: map
        }

  @derive Jason.Encoder
  defstruct defaults: %{},
            tunnels: %{}

  @context "tunnel"

  @spec handle_input(Input.t()) :: {:ok, Output.t()} | {:error, atom, Output.t()}
  def handle_input(%Input{} = input) do
    Tunnel.Input.handle_input(input)
  end

  @spec get_config :: Tunnel.t()
  def get_config do
    struct!(Tunnel, Config.Manager.get_config(@context))
  rescue
    _error -> %Tunnel{}
  end

  @spec clear_config :: :ok | {:error, atom}
  def clear_config do
    Config.Manager.clear_config(@context)
  end

  @spec save_config(Tunnel.t()) :: :ok
  def save_config(%Tunnel{} = config) do
    Config.Manager.save_config(@context, config)
  end

  @spec has_tunnel?(String.t()) :: boolean
  def has_tunnel?(name) do
    has_tunnel?(name, get_config())
  end

  @spec has_tunnel?(String.t(), Tunnel.t()) :: boolean
  def has_tunnel?(name, %Tunnel{tunnels: tunnels}) do
    Map.has_key?(tunnels, String.to_atom(name))
  end

  @spec add_tunnel(Tunnel.Input.Add.t()) :: {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def add_tunnel(%Tunnel.Input.Add{} = input) do
    add_tunnel(input, get_config())
  end

  @spec add_tunnel(Tunnel.Input.Add.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom(), Output.t()}
  def add_tunnel(%Tunnel.Input.Add{} = input, %Tunnel{} = config) do
    Tunnel.Operations.add_tunnel(input, config)
  end

  @spec edit_tunnel(Tunnel.Input.Edit.t()) :: {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def edit_tunnel(%Tunnel.Input.Edit{} = input) do
    edit_tunnel(input, get_config())
  end

  @spec edit_tunnel(Tunnel.Input.Edit.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def edit_tunnel(%Tunnel.Input.Edit{} = input, %Tunnel{} = config) do
    Tunnel.Operations.edit_tunnel(input, config)
  end

  @spec remove_tunnel(Tunnel.Input.Remove.t()) :: {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def remove_tunnel(%Tunnel.Input.Remove{} = input) do
    remove_tunnel(input, get_config())
  end

  @spec remove_tunnel(Tunnel.Input.Remove.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def remove_tunnel(%Tunnel.Input.Remove{} = input, %Tunnel{} = config) do
    Tunnel.Operations.remove_tunnel(input, config)
  end

  @spec set_default_tunnel(Tunnel.Default.Input.Set.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def set_default_tunnel(%Tunnel.Default.Input.Set{} = input) do
    set_default_tunnel(input, get_config())
  end

  @spec set_default_tunnel(Tunnel.Default.Input.Set.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def set_default_tunnel(%Tunnel.Default.Input.Set{} = input, %Tunnel{} = config) do
    Tunnel.Default.Operations.set_default_tunnel(input, config)
  end

  @spec unset_default_tunnel(Tunnel.Default.Input.Unset.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def unset_default_tunnel(%Tunnel.Default.Input.Unset{} = input) do
    unset_default_tunnel(input, get_config())
  end

  @spec unset_default_tunnel(Tunnel.Default.Input.Unset.t(), Tunnel.t()) ::
          {:ok, Tunnel.t()} | {:error, atom, Output.t()}
  def unset_default_tunnel(%Tunnel.Default.Input.Unset{} = input, %Tunnel{} = config) do
    Tunnel.Default.Operations.unset_default_tunnel(input, config)
  end
end

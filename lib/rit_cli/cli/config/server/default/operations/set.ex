defmodule RitCLI.CLI.Config.Server.Default.Operations.Set do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Server.Default.Input

  @spec set_default_server(Input.Set.t(), Config.Server.t()) ::
          {:ok, Config.Server.t()} | {:error, atom, Output.t()}
  def set_default_server(
        %Input.Set{name: name, path: path},
        %Config.Server{defaults: defaults} = config
      ) do
    if Config.Server.has_server?(name, config) do
      defaults =
        if path != "" do
          Map.put(defaults, String.to_atom(path), name)
        else
          Map.put(defaults, :*, name)
        end

      {:ok, struct(config, defaults: defaults)}
    else
      {
        :error,
        :config_server_set_default_not_found,
        %Output{
          error: "Server '#{name}' not found",
          module_id: :config_server_set_default
        }
      }
    end
  end
end

defmodule RitCLI.CLI.Config.Server.Operations.UnsetDefault do
  @moduledoc false

  alias RitCLI.CLI.{Config, Output}
  alias RitCLI.CLI.Config.Server.Input

  @spec unset_default_server(Input.UnsetDefault.t(), Config.Server.t()) ::
          {:ok, Config.Server.t()} | {:error, atom(), Output.t()}
  def unset_default_server(
        %Input.UnsetDefault{path: path},
        %Config.Server{defaults: defaults} = config
      ) do
    path = String.to_atom(path)

    if Map.has_key?(defaults, path) do
      {:ok, struct!(config, defaults: Map.drop(defaults, [path]))}
    else
      message =
        if path != :* do
          "There are no default servers set on path"
        else
          "There are no global default server set"
        end

      {
        :error,
        :config_server_unset_default_input_error,
        %Output{
          error: message,
          module_id: :config_server_unset_default
        }
      }
    end
  end
end

defmodule RitCLI.Tunnel.Run.Handler.Execute.EnvironmentManager do
  @moduledoc false

  @spec interpolate(String.t(), map) :: String.t()
  def interpolate(operation, environment) do
    Regex.replace(~r/\$[{]*(\w+)[}]*/, operation, fn _match, env ->
      case Map.get(environment, env) do
        nil -> System.get_env(env, "")
        env -> env
      end
    end)
  end

  @spec build_list_of_tuples(map) :: list({String.t(), String.t()})
  def build_list_of_tuples(environment) do
    Enum.map(environment, fn {key, value} -> {key, value} end)
  end
end

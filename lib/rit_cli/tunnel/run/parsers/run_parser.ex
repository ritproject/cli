defmodule RitCLI.Tunnel.Run.RunParser do
  @moduledoc false

  alias RitCLI.Meta.Error

  @spec parse(map) :: {:ok, any} | {:error, Error.t()}
  def parse(settings) do
    case Map.get(settings, "run") do
      nil -> {:error, run_not_found_error()}
      result -> {:ok, result}
    end
  end

  defp run_not_found_error do
    Error.build(
      __MODULE__,
      :invalid_settings,
      "run key on referenced settings does not exists"
    )
  end
end

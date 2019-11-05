defmodule RitCLI.Tunnel.Run.Parameters.LinkDirParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "link_dir") do
      nil -> runner
      link_dir -> struct(runner, link_dir: link_dir)
    end
  end
end

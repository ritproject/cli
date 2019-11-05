defmodule RitCLI.Tunnel.Run.Parameters.LinkModeParser do
  @moduledoc false

  alias RitCLI.Tunnel.Run.Runner

  @spec parse(Runner.t()) :: Runner.t()
  def parse(%Runner{} = runner) do
    case Map.get(runner.settings, "link_mode") do
      "copy" -> struct(runner, link_mode: :copy)
      "symlink" -> struct(runner, link_mode: :symlink)
      "none" -> struct(runner, link_mode: :none)
      _unknown -> runner
    end
  end
end

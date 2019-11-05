defmodule RitCLITest.RitCLI.Tunnel.Run.Handler.Execute.ExecutorTest do
  use ExUnit.Case

  alias RitCLI.Main
  alias RitCLI.Meta
  alias RitCLI.Tunnel.Run.Handler.Execute.Executor
  alias RitCLI.Tunnel.Run.Runner

  describe "Executor.execute/2" do
    test "invalid source path, return {:error, Meta.t()}" do
      meta = %Meta{
        main: %Main{
          output_mode: :inspect
        }
      }

      runner = %Runner{
        operation: "sleep 0",
        source_path: "/unknown"
      }

      assert {:error, %Meta{}} = Executor.execute(meta, runner)
    end
  end
end

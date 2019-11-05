defmodule RitCLITest.RitCLI.Config.Tunnel.ArgumentsParser do
  use ExUnit.Case

  alias RitCLI.Config.Tunnel.ArgumentsParser
  alias RitCLI.Meta.Error

  describe "ArgumentsParser.parse_reference/3" do
    test "with empty value, expose error" do
      assert {:error, %Error{}} = ArgumentsParser.parse_reference("", "local", :reference)
    end
  end
end

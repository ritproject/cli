defmodule RitCLITest.RitCLI.Config.StorageManagerTest do
  use ExUnit.Case

  alias RitCLI.Config.StorageManager
  alias RitCLI.Meta.Error

  @storage "test"

  setup_all do
    StorageManager.clear_storage(@storage)
  end

  setup do
    on_exit(fn -> StorageManager.clear_storage(@storage) end)
  end

  describe "StorageManager.save_storage/2" do
    test "fails when config is not parceable as JSON" do
      assert {:error, %Error{}} = StorageManager.save_storage(@storage, i_will: "fail")
    end
  end

  describe "StorageManager.clear_storage/1" do
    test "fails when config is not allowed to be removed" do
      home = System.get_env("HOME", "")
      path = "#{home}/.rit/config/test.json"
      File.mkdir_p!(path)

      try do
        assert {:error, %Error{}} = StorageManager.clear_storage(@storage)
      after
        File.rmdir!(path)
      end
    end
  end
end

ExUnit.configure(exclude: [pending: true])

ExUnit.start()

Enum.each(File.ls!("./test/utils"), fn file -> Code.require_file("utils/#{file}", __DIR__) end)

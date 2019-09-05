defmodule RitCLITest.CLI.Tunnel.RunTest do
  use ExUnit.Case, async: false

  alias RitCLI.CLI.Config

  import ExUnit.CaptureIO

  describe "command: rit tunnel run" do
    test "with valid settings and operations, do: run command successfully" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link

          .error:
            run: cat unknown.txt

            .test: echo test

          .test:
            redirect:
              to: test
              external: true
        """

        File.write!("/test/test/tunnel.yml", yaml)

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link

          .a:
            direct: echo a

            .b: echo b

          .c:
            environment:
              TEST: test
            run:
              - echo c
              - echo c2

          .d:
            run: echo d

            .e:
              run:
                - echo e
                - echo e2

            .f: echo f

            .g:
              redirect:
                to: d e
                strict: true
        """

        File.write!("/test/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run test)
        assert RitCLI.main(argv ++ ~w(a b)) == :ok
        assert RitCLI.main(argv ++ ~w(c)) == :ok
        assert RitCLI.main(argv ++ ~w(d g)) == :ok
        assert catch_exit(RitCLI.main(~w(tunnel run error test))) == {:shutdown, 1}
      end

      message = """
      b

      Tunnelling successfully performed
      c

      c2

      Tunnelling successfully performed
      d

      e

      e2

      Tunnelling successfully performed
      /bin/cat: unknown.txt: No such file or directory

      Error: Tunnel operation 'cat unknown.txt' failed, exit code: 1

      """

      assert capture_io(execution) == message

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test/test/test")

        yaml = """
        version: '0.0.1'

        run:
          redirect:
            to: test
            external: true
        """

        File.write!("/test/test/tunnel.yml", yaml)

        yaml = """
        version: '0.0.1'

        run:
          .a:
            .b:
              redirect:
                to: test
                external: true
        """

        File.write!("/test/test/test/tunnel.yml", yaml)

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link
          .test: echo test
        """

        File.write!("/test/test/test/test/tunnel.yml", yaml)
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        assert RitCLI.main(~w(tunnel run a b test)) == :ok
      end

      message = """
      test

      Tunnelling successfully performed
      """

      assert capture_io(execution) == message
    end

    test "without default tunnel set, do: explain not set" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to find default config

      """

      assert capture_io(execution) == error_message
    end

    test "with default set with corrupted config, do: explain undefined" do
      assert Config.Tunnel.clear_config() == :ok

      data =
        %{
          tunnels: %{},
          defaults: %{*: "test"}
        }
        |> Jason.encode!()

      File.mkdir_p("/root/.rit/config")
      File.write("/root/.rit/config/tunnel.json", data)

      execution = fn ->
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to find config with name 'test'

      """

      assert capture_io(execution) == error_message
    end

    test "with local default set with inexistent dir, do: explain undefined" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test")
        assert RitCLI.main(~w(config tunnel add local /test)) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
        File.rmdir("/test")
      end

      capture_io(execution)

      execution = fn ->
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel local reference 'test' on path '/test' does not exist

      """

      assert capture_io(execution) == error_message
    end

    test "with repo default set with invalid link, do: explain fetch failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://gitlab.com/ritproject/unknown --name test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to fetch data from repo 'test' with link 'https://gitlab.com/ritproject/unknown'

      """

      assert capture_io(execution) == error_message
    end

    test "with repo default set with local set without git, do: explain fetch failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://gitlab.com/ritproject/unknown --name test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        File.mkdir_p("/root/.rit/tunnel/test")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to fetch data from repo 'test' with link 'https://gitlab.com/ritproject/unknown'

      """

      assert capture_io(execution) == error_message
    end

    test "with repo default set and no settings set, do: explain not found" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        argv = ~w(config tunnel add repo https://gitlab.com/ritproject/cli --name test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed find tunnel YAML file

      """

      assert capture_io(execution) == error_message
    end

    test "with invalid .yaml set, do: explain invalid" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test")
        File.write("/test/tunnel.yaml", "!!! INVALID")

        argv = ~w(config tunnel add local /test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to parse YAML file

      """

      assert capture_io(execution) == error_message
    end

    test "with no root run on .yml set, do: explain undefined" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test")

        yaml = """
        version: '0.0.1'
        """

        File.write("/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to identify run on settings

      """

      assert capture_io(execution) == error_message
    end

    test "with no run operation on .yml set, do: explain undefined" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link
          environment:
            TEST: test
        """

        File.write("/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to identify operation to perform on settings

      """

      assert capture_io(execution) == error_message
    end

    test "with invalid link_dir set, do: explain failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: ../test

          .test:
            redirect:
              to: echo

          .echo: echo TEST
        """

        File.write("/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to create symbolic link

      """

      assert capture_io(execution) == error_message
    end

    test "with no link_dir set, do: explain failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test")

        yaml = """
        version: '0.0.1'

        run:
          direct:
            - echo TEST
            - echo AS A LIST
        """

        File.write("/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to identify 'link_dir' on settings

      """

      assert capture_io(execution) == error_message
    end

    test "with invalid operation set, do: explain failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link
          direct: unknown command
        """

        File.write("/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel operation 'unknown command' failed, exit code: 1

      """

      assert capture_io(execution) == error_message
    end

    test "with invalid final argument, do: explain failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link

          .test:
            run: echo TEST
        """

        File.write("/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run test unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed to identify operation to perform on settings

      """

      assert capture_io(execution) == error_message
    end

    test "with error on list operations, do: explain failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link

          .test:
            run: echo TEST

            .list:
              - echo TEST
              - echo TEST
              - unknown command
              - echo TEST
        """

        File.write("/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run test list unknown)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel operation 'unknown command' failed, exit code: 1

      """

      assert capture_io(execution) =~ error_message
    end

    test "with unknown redirection, do: explain failure" do
      assert Config.Tunnel.clear_config() == :ok

      execution = fn ->
        File.rm_rf("/test")
        File.mkdir_p("/test/test")

        yaml = """
        version: '0.0.1'

        run:
          link_dir: link

          .test:
            redirect:
              to: redirect
              strict: true

          .redirect:
            redirect:
              to: unknown
              external: true
        """

        File.write("/test/test/tunnel.yml", yaml)

        argv = ~w(config tunnel add local /test/test)
        assert RitCLI.main(argv) == :ok
        assert RitCLI.main(~w(config tunnel default set test)) == :ok
      end

      capture_io(execution)

      execution = fn ->
        File.rm_rf("/root/.rit/tunnel")
        argv = ~w(tunnel run test)
        assert catch_exit(RitCLI.main(argv)) == {:shutdown, 1}
      end

      error_message = """
      Error: Tunnel failed find tunnel YAML file

      """

      assert capture_io(execution) == error_message
    end
  end
end

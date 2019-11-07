defmodule RitCLITest.TunnelSettings do
  @run """
  version: '0.0.1'
  run: echo hello world
  """

  def set(:run) do
    write(@run, 1)
  end

  @list """
  version: '0.0.1'
  run:
    - echo hello
    - echo world
  """

  def set(:list) do
    write(@list, 1)
  end

  @redirect_internal """
  version: '0.0.1'

  run:
    .hello:
      run: echo hello

      .redirect:
        redirect:
          to: world

    .world: echo world
  """

  def set(:redirect_internal) do
    write(@redirect_internal, 1)
  end

  @redirect_external_parent """
  version: '0.0.1'

  run:
    .hello:
      run: echo hello

      .redirect:
        redirect:
          to: test
          external: true
  """

  @redirect_external_child """
  version: '0.0.1'

  run: echo world
  """

  def set(:redirect_external) do
    write(@redirect_external_parent, 1)
    write(@redirect_external_child, 2)
  end

  @redirect_external_child_composite """
  version: '0.0.1'

  run:
    .external: echo world
  """

  def set(:redirect_external_composite) do
    write(@redirect_external_parent, 1)
    write(@redirect_external_child_composite, 2)
  end

  def set(:redirect_external_no_child) do
    write(@redirect_external_parent, 1)
  end

  def set(:redirect_external_no_child_depth_three) do
    write(@redirect_external_parent, 1)
    write(@redirect_external_parent, 2)
  end

  @redirect_external_internal_parent """
  version: '0.0.1'

  run:
    redirect:
      to: test
      external: true
  """

  def set(:redirect_external_internal) do
    write(@redirect_external_internal_parent, 1)
    write(@redirect_internal, 2)
  end

  @redirect_strict """
  version: '0.0.1'

  run:
    redirect:
      to: only show hello_world
      strict: true

    .only:
      run: echo only

      .show:
        run: echo show

        .hello_world:
          redirect:
            to: show hello_world

    .show:
      run: echo show

      .hello_world: echo hello world
  """

  def set(:redirect_strict) do
    write(@redirect_strict, 1)
  end

  @input """
  version: '0.0.1'

  run:
    input:
      message:
        environment_name: MESSAGE

    run: echo $MESSAGE
  """

  def set(:input) do
    write(@input, 1)
  end

  @input_with_default """
  version: '0.0.1'

  run:
    link_mode: none

    input:
      message:
        environment_name: MESSAGE
        defaults_to: hello world

    run: echo $MESSAGE
  """

  def set(:input_with_default) do
    write(@input_with_default, 1)
  end

  @link_mode_symlink """
  version: '0.0.1'

  run:
    link_dir: ./test
    link_mode: symlink

    run: cat ./test/hello_world.txt
  """

  def set(:link_mode_symlink) do
    write(@link_mode_symlink, 1)
    write_txt("hello_world", "hello world\n")
  end

  @link_mode_copy """
  version: '0.0.1'

  run:
    link_dir: ./test
    link_mode: copy

    run: cat ./test/hello_world.txt
  """

  def set(:link_mode_copy) do
    write(@link_mode_copy, 1)
    write_txt("hello_world", "hello world\n")
  end

  @link_mode_without_link_dir """
  version: '0.0.1'

  run:
    link_mode: copy

    run: cat ./test/hello_world.txt
  """

  def set(:link_mode_without_link_dir) do
    write(@link_mode_without_link_dir, 1)
  end

  @link_dir_invalid """
  version: '0.0.1'

  run:
    link_dir: ./unknown/directory
    link_mode: copy

    direct: cat ./test/hello_world.txt
  """

  def set(:link_dir_invalid) do
    write(@link_dir_invalid, 1)
  end

  @no_operation """
  version: '0.0.1'

  run:
    .no
      .operation:
        environment:
          TEST_WILL_FAIL: indeed
  """

  def set(:no_operation) do
    write(@no_operation, 1)
  end

  @fail_on_joined_run """
  version: '0.0.1'

  run:
    .success:
      run:
        - print $ENVIRONMENT_VARIABLE
        - sleep 0

      .fail:
        environment:
          TEST_WILL_FAIL: indeed

        run: cat unknown.txt

        .success:
          run: sleep 0
  """

  def set(:fail_on_joined_run) do
    write(@fail_on_joined_run, 1)
  end

  @run_not_found """
  version: '0.0.1'
  """

  def set(:run_not_found) do
    write(@run_not_found, 1)
  end

  @invalid_argument """
  version: '0.0.1'
  run:
    .invalid: true
  """

  def set(:invalid_argument) do
    write(@invalid_argument, 1)
  end

  @invalid_yaml "!!! INVALID"

  def set(:invalid_yaml) do
    write(@invalid_yaml, 1)
  end

  def write(yaml, level) do
    file =
      if rem(level, 2) == 0 do
        "/tunnel.yml"
      else
        "/tunnel.yaml"
      end

    path = String.duplicate("/test", level)
    File.mkdir_p!(path)
    File.write!(path <> file, yaml)
  end

  def write_txt(file_name, data) do
    File.write!("/test_target/#{file_name}.txt", data)
  end

  def clear do
    File.rm_rf!("/test")
    File.rm_rf!("/test_target")
  end

  def reset do
    clear()
    File.mkdir_p!("/test")
    File.mkdir_p!("/test_target")
  end
end

# Tunnel

Tunnel is an interface to perform operations from a source directory to target
directory.

Source directory can be either a local directory or a git repository.

With tunnel, you can:

- Uncouple and automate the development setup files from your project directory
- Improve and/or simplify CI operations
- Create common operations and use it everywhere
- Copy, fetch, or manage git ignored files to a project
- Etc.

## Getting started

In order to use tunnel, it is necessary to define a source directory with the
command `rit config tunnel add` and reference it when using `rit tunnel`.

### Hello tunnel

First, create a local directory to be your source:

```bash
mkdir source
```

Using your favorite text editor, create the settings file `source/tunnel.yaml`:

```yaml
version: '0.0.1'

run: echo hello tunnel
```

Add the tunnel source to your configuration:

```bash
rit config tunnel add local source
```

The output should be:

```bash
[success] tunnel config 'source' saved
```

Finally, use it anywhere:

```bash
rit tunnel --config source run
```

The output will be:

```bash
hello tunnel

[success] tunnel successfully performed the operation
```

### Copying files

To copy a source file to a target path, first create a file in source
directory, such as `source/secrets.py`:

```python
A_SECRET = 'SUCH_SECRET_MUCH_WOW'

SOME_PRODUCTION_CONTEXT_SECRET = 'SOME_PRODUCTION_CONTEXT_VALUE'
```

Modify your `source/tunnel.yaml`:

```yaml
version: '0.0.1'

run:
  .hello: echo hello tunnel

  .copy:
    link_dir: ./target
    link_mode: symlink

    run: cp secrets.py target/
```

Finally, use it anywhere:

```bash
rit tunnel --config source run copy
```

The output will be:

```bash
[success] tunnel successfully performed the operation
```

### Set default source configuration

To simplify the tunnel usage, you can set either a global or local
default configuration.

A local configuration is used whenever a `--config` is not defined and the
target path contains a default source.

A global configuration is used whenever both `--config` and a local
configuration is not set.

Both types can be set by using `rit config tunnel default set`.

For example, to set a global default source configuration, use:

```bash
rit config tunnel default set source
```

The output will be:

```bash
[success] tunnel config 'source' set as global default
```

To set a local default source configuration in your current directory, use:

```bash
rit config tunnel default set source --path .
```

The output will be similar to:

```bash
[success] tunnel config 'source' set as default on path '/current/path'
```

To list all your tunnel source configurations, use:

```bash
rit config tunnel list
```

The output will be similar to:

```markdown
# Tunnels Configs

- source: /path/to/source (local)

## Default Paths

- (global): source
- /current/path: source
```

Finally, you can use `rit tunnel` without the `--config` modifier:

```bash
rit tunnel run hello
```

### Additional settings

Please check the section below to discover all the parameters and operators
available to use in a YAML settings file.

## Settings parameters and Settings operators

Settings parameters allows to configure how the operation will be performed.

Settings operators allows to define the operation itself.

### Settings parameters

#### `environment`

Set one or more environment variables to be used by any of the children operators.

- Pattern:

  ```yaml
  environment:
    [<ENV_NAME>: <ENV_VALUE>]+
  ```

- Examples:

  ```yaml
  environment:
    NODE_ENV: production

  run: yarn build
  ```

  ```yaml
  environment:
    PARSE_FILES: 'true'
    EXPORT_AS: json

  run: ./parser $PARSE_FILES $EXPORT_AS
  ```

#### `input`

Set one or more environment variables that can be defined by the user before
performing a operation. Ensure `defaults_to` is set to avoid errors when
executing operations without input enabled.

- Pattern:

  ```yaml
  input:
    [<KEY>:
      environment_name: <ENV_NAME>
      defaults_to: <ENV_VALUE>]+
  ```

- Examples:

  ```yaml
  input:
    NODE_ENV:
      defaults_to: production

  run: yarn build
  ```

  ```yaml
  input:
    parse_files?:
      environment_name: PARSE_FILES
      defaults_to: 'true'
    export_as:
      environment_name: EXPORT_AS
      defaults_to: json

  run: ./parser $PARSE_FILES $EXPORT_AS
  ```

#### `link_dir`

Set the path relative to the current settings directory to fetch the files from
target directories. The fetch will be performed only if both `link_dir` and
`link_mode` are set.

- Pattern:

  ```yaml
  link_dir: <LINK_DIR>
  ```

- Examples:

  ```yaml
  link_dir: ./app
  link_mode: copy

  run: docker-compose up
  ```

  ```yaml
  link_dir: ./data_source
  link_mode: symlink

  run: cp data.csv data_source/
  ```

#### `link_mode`

Set how to fetch the target at `link_dir`. The fetch will be performed only if both `link_dir` and `link_mode` are set.

- Options:

  - `copy`: Copy the target to the tunnel directory. Use it whenever you want
    to ensure the state of the target directory will not change.
  - `symlink`: Create a symbolic link at the tunnel directory. Use it whenever
    you want to change the state of the target directory.
  - `none` (default): Do not perform any tunnel. Use it whenever you want to
    perform operations without the need to bind directories.
- Pattern:

  ```yaml
  link_mode: <copy|symlink|none>
  ```

- Examples:

  ```yaml
  link_dir: ./app
  link_mode: copy

  run: docker-compose up
  ```

  ```yaml
  link_dir: ./data_source
  link_mode: symlink

  run: cp data.csv data_source/
  ```

  ```yaml
  link_mode: none

  run: echo hello world
  ```

### Settings operators

An operation can be either a command or a list of commands.

#### `.argument`

An argument operator is used to set a graph to define multiple operations. A
child argument inherit all the parameters set in all its parents. A sibling
argument shares the parameters from its parents and from the current context.

- Pattern:

  ```yaml
  .<ARG_NAME>:
    ...

    [.<CHILD_ARG_NAME>:
      ...]*

  [.<SIBLING_ARG_NAME>:
    ...]*
  ```

- Example:

  ```yaml
  run:
    .hello:
      run: echo hello

      .world:
        run: echo world

      .name:
        input:
          NAME:
            defaults_to: Jon
          SURNAME:
            defaults_to: Doe

        direct: echo $NAME $SURNAME

        .joana: echo Joana $SURNAME

        .snow: echo $NAME Snow
  ```

  ```bash
  $ rit tunnel run hello
  hello

  $ rit tunnel run hello world
  hello
  world

  $ rit tunnel run hello name
  hello
  Jon Doe

  $ rit tunnel run hello name joana
  hello
  Joana Doe

  $ rit tunnel run hello name snow
  hello
  Jon Snow
  ```

#### `direct`

An direct operator is used to set a operation that will be executed ONLY if
the arguments received is exactly the same as the path to the parent argument
operator. If the path continues, it will not be executed.

- Pattern:

  ```yaml
  direct: [<COMMAND>]+
  ```

- Example:

  ```yaml
  run:
    .hello:
      direct: echo hello

      .world:
        direct: echo world

      .there:
        direct:
          - echo hello there
          - echo general Kenobi!
  ```

  ```bash
  $ rit tunnel run hello
  hello

  $ rit tunnel run hello world
  world

  $ rit tunnel run hello there
  hello there
  general Kenobi!
  ```

#### `redirect`

An redirect operator is an special operation used to redirect the current path
to another path or to another settings file. If `strict` option is set to
`true`, it will execute only the command defined in the last argument set by
`to` option.

- Pattern:

  ```yaml
  redirect:
    to: <INTERNAL_OR_EXTERNAL_PATH>
    external: <true|false (default)>
    strict: <true|false (default)>
  ```

- Internal example:

  ```yaml
  run:
    .hello:
      run: echo hello

      .world:
        run: echo world

    .hi:
      redirect:
        to: hello

    .goodbye:
      .forever: echo goodbye
      .swag: echo hasta la vista, baby
      .nvm:
        redirect:
          to: hello world
          strict: true
  ```

  ```bash
  $ rit tunnel run hello
  hello

  $ rit tunnel run hello world
  hello
  world

  $ rit tunnel run hi
  hello

  $ rit tunnel run hi world
  hello
  world

  $ rit tunnel run goodbye forever
  goodbye

  $ rit tunnel run goodbye swag
  hasta la vista, baby

  $ rit tunnel run goodbye nvm
  world
  ```

- External example:

  ```bash
  example
  ├── tunnel.yml
  └── outsider
       └── tunnel.yml
  ```

  ```yaml
  # example/tunnel.yml

  run:
    .hello:
      run: echo hello

      .world:
        run: echo world

      .outsider:
        redirect:
          to: outsider
          external: true
  ```

  ```yaml
  # example/outsider/tunnel.yml

  run:
    direct: echo what?

    .ola: echo ola!
  ```

  ```bash
  $ rit tunnel hello
  hello

  $ rit tunnel hello world
  hello
  world

  $ rit unnel hello outsider
  hello
  what?

  $ rit tunnel hello outsider ola
  hello
  ola!
  ```

#### `run`

Run is the basic operator type and will be run whenever its path is a subset
of the arguments, except on `strict` `redirect`. A root `run` operator must be
set in each settings file, otherwise rit will fail.

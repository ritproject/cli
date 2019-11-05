defmodule RitCLI.Meta.Helper do
  @moduledoc false

  @spec to_string(module, keyword) :: String.t()
  def to_string(RitCLI.Config, _opts) do
    """
    usage: rit config <type> [<type_argument>]*

    Select a config type to execute commands.

    Types:
      h, help               Show this message
      t, tunnel, tunnels    Select tunnel config type
    """
  end

  def to_string(RitCLI.Config.Tunnel, _opts) do
    """
    usage: rit config tunnel <command> [<command_argument>]*

    Select a config tunnel command to execute.

    Commands:
      a, add        Create new tunnel configuration
      d, default    Manage default tunnel configuration
      e, edit       Update existing tunnel configuration
      h, help       Show this message
      l, list       Show all existing tunnel configurations
      r, remove     Remove existing tunnel configuration
      s, show       Show existing tunnel configuration
    """
  end

  def to_string(RitCLI.Config.Tunnel.Add, _opts) do
    """
    usage: rit config tunnel add <from> <reference> --name <name>

    Create new tunnel configuration.

    Arguments:
      <from>         Origin type of the source reference

                     From options:
                       repo     From a git remote repository
                                  <reference> must be valid URL

                       local    From a local directory
                                  <reference> must be valid existing local path

      <reference>    Source reference

    Option:
      --name     Tunnel configuration name
                   If blank, defaults to the last segment of <reference>
    """
  end

  def to_string(RitCLI.Config.Tunnel.Default, _opts) do
    """
    usage: rit config tunnel default <command> [<command_argument>]*

    Select a default config tunnel command to execute.

    Commands:
      h, help     Show this message
      s, set      Set existing tunnel configuration as default
      u, unset    Unset existing default tunnel configuration
    """
  end

  def to_string(RitCLI.Config.Tunnel.Default.Set, _opts) do
    """
    usage: rit config tunnel default set <name> --path <path>

    Set existing tunnel configuration as default.

    Argument:
      <name>    Name of existing tunnel configuration

    Option:
      --path    Path to set configuration as default
                  If blank, it will set tunnel configuration as global default
    """
  end

  def to_string(RitCLI.Config.Tunnel.Default.Unset, _opts) do
    """
    usage: rit config tunnel default unset --path <path>

    Unset existing default tunnel configuration.

    Option:
      --path    Path to unset default configuration
                  If blank, it will unset global default tunnel configuration
    """
  end

  def to_string(RitCLI.Config.Tunnel.Edit, _opts) do
    """
    usage: rit config tunnel edit <current_name>
                                  --from <from>
                                  --name <name>
                                  --reference <reference>

    Update existing tunnel configuration.

    Argument:
      <current_name>    Existing tunnel configuration name

    Options:
      --from         Update tunnel origin type of the source reference

                     From options:
                       repo     From a git remote repository
                                  <reference> must be valid URL
                       local    From a local directory
                                  <reference> must be valid existing local path

      --name         Update tunnel configuration name
                       If blank, defaults to the last segment of <reference>

      --reference    Update source reference
    """
  end

  def to_string(RitCLI.Config.Tunnel.List, _opts) do
    """
    usage: rit config tunnel list

    Show all existing tunnel configurations.
    """
  end

  def to_string(RitCLI.Config.Tunnel.Remove, _opts) do
    """
    usage: rit config tunnel remove <name>

    Remove existing tunnel configuration.

    Argument:
      <name>    Existing tunnel configuration name
    """
  end

  def to_string(RitCLI.Config.Tunnel.Show, _opts) do
    """
    usage: rit config tunnel show <name>

    Show existing tunnel configuration.

    Argument:
      <name>    Existing tunnel configuration name
    """
  end

  def to_string(RitCLI.Tunnel, _opts) do
    """
    usage: rit tunnel [<modifier> <mode>]* <command> [<command_argument>]*

    Run commands from tunnel source to target directory.

    Contexts:
      h, h       Show this message
      l, list    Show available run operations
      r, run     Execute tunnel source operation

    Modifiers:
      -c, --config    Set tunnel config (overriding default, if exists)

      -i, --input     Set input mode

                      Input modes:
                        d, disabled     Do not prompt input
             (default)  e, enabled      Prompt input

      -p, --path      Set target path (overriding current path)
    """
  end

  def to_string(_module, _opts) do
    """
    usage: rit [<modifier> <mode>]* <context> [<context_argument>]*

    Select a context to execute commands.

    Contexts:
      c, config             Select config context
      h, help               Show this message
      t, tunnel, tunnels    Select tunnel context

    Modifiers:
      -l, --log       Set log mode

                      Log modes:
                        b, batch       Show logs after execution
             (default)  d, disabled    Do not show logs
                        o, on_error    Show logs after failed execution

      -o, --output    Set output mode

                      Output modes:
                        i, inspect      Show output as Elixir map
                        j, json         Show output as prettified JSON
             (default)  p, plain        Show output normally
                        u, ugly_json    Show output as uglified JSON
    """
  end
end

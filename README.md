# Rit CLI

[![pipeline status](https://gitlab.com/ritproject/cli/badges/master/build.svg)](https://gitlab.com/ritproject/cli/commits/master)
[![coverage report](https://gitlab.com/ritproject/cli/badges/master/coverage.svg)](https://gitlab.com/ritproject/cli/commits/master)

Command line tools to aid developers on daily work.

At the moment, this project is not meant to be used as Elixir library, although
it is possible by adding as dependency in your `mix.exs` file:

```elixir
def deps do
  [{:rit_cli, "~> 0.0.1"}]
end
```

Check [Rit CLI](https://hex.pm/packages/rit_cli) for detailed information about
tools usage.

## Installation

### Self-contained

Download the latest version at <https://gitlab.com/ritproject/cli/-/wiki_pages/home>

Save it in a directory and add `<saved_directory>/rit/bin` to your `PATH` (or
create an `alias` into your terminal configuration file)

### Running with Docker

Running a single time without binding volumes:

```bash
docker run -it --rm ritproject/cli help
```

To save or bind rit configuration files:

```bash
docker run -it --rm -v path/to/user/.rit:/root/.rit ritproject/cli help
```

In order to run the majority of the functionalities of Rit CLI, you will need
to bind the projects directories into container:

```bash
docker run -it --rm -v host/path/to/project:/container/path/to/project -w /container/path/to/project help
```

**Note**: Remember to always use the same path for each project you bind.

Full command:

```bash
docker run -it --rm \
  -v path/to/user/.rit:/root/.rit \
  -v host/path/to/project:/container/path/to/project \
  -w /container/path/to/project
  ritproject/cli help
```

To run with docker-compose, create a `docker-compose.yml` file:

```yaml
version: '3.7'

services:
  rit:
    image: ritproject/cli
    working_dir: /container/path/to/project
    volumes:
      - path/to/user/.rit:/root/.rit
      - host/path/to/project:/container/path/to/project
```

Runnning with docker-compose:

```bash
docker-compose run --rm rit help
```

An example to simplify the usage of Rit CLI by binding the project on container
with the same path as your machine:

- With docker:

  ```bash
  docker run -it --rm \
    -v path/to/user/.rit:/root/.rit \
    -v ${PWD}:${PWD}
    -w ${PWD}
    ritproject/cli help
  ```

- With docker-compose:

  ```yaml
  version: '3.7'

  services:
    rit:
      image: ritproject/cli
      working_dir: ${PWD}
      volumes:
        - path/to/user/.rit:/root/.rit
        - ${PWD}:${PWD}
  ```

You can set an alias into your terminal configuration to simplify the usage:

```bash
# with docker
alias rit='docker run -it --rm -v path/to/user/.rit:/root/.rit -v ${PWD}:${PWD} -w ${PWD} ritproject/cli'
# with docker-compose
alias rit='docker-compose -f /abs/path/to/docker-compose.yml run --rm rit'
```

After fetching the terminal configuration, you can run Rit CLI normally:

```bash
rit help
```

### From source code

Rit ecosystem is made entirely with Elixir, which means in order to install
Rit CLI source code on your machine, it is necessary to install Erlang and
Elixir first.

Even if it is not a common language and installing a new language on your
machine is kind of a huge dependency for a simple CLI tool, Erlang and Elixir
are great languages to develop with a nice community and great libraries
available.

If you never heard about Elixir, consider this installation as your first step
into an incredible functional programming platform!

#### Installing Erlang or Elixir

To install elixir on your machine, please follow this link:
<https://elixir-lang.org/install.html>

Elixir needs Erlang and will install it on the installation process.

If you just want to install Erlang, check your package manager for `erlang`
or follow this link: <http://erlang.org/doc/installation_guide/INSTALL.html>

#### Installing Rit CLI with escript

Simply run:

```bash
mix escript.install github ritproject/cli
# or from GitLab
mix escript.install git https://gitlab.com/ritproject/cli
```

If `~/.mix/escripts` are not on your `PATH`, consider adding it to invoke the
escripts installed on your machine by name.

Another option is to create an `alias` into your terminal configuration file:

```bash
alias rit='/abs/path/to/.mix/escripts/rit'
```

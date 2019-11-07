# Changelog

## 0.0.2 - 2019-11-07

- **Added**:

  - `rit v | rit version` exposing current commit hash (short) and tag version.
- **Changed**:

  - `rit tunnel run` environment fetching now prioritizes system environment
    variables. New precedence order:

    - System environment variable -> Input parameter -> Environment parameter
- **Fixed**:

  - Solved `rit tunnel list --depth` acting as length instead of depth.
  - Solved `rit tunnel list` with sibling external redirections resulting in
    incorrect settings error.
  - Solved `rit tunnel run` without `--path` modifier failing to link current
    directory with the source directory.

## 0.0.1 - 2019-11-05

- **Added**:

  - The project is available on GitLab and Hex.

- **Notes**:

  - Minor changes (0.0.x) from the current version will be logged to this file.
  - When a major change is released (0.x.0 or x.0.0), the changelog of the
    previous major change will be grouped as a single change.

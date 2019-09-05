defmodule RitCLI.CLI.Config.Server.Validator do
  @moduledoc false

  alias RitCLI.CLI.Input.Validator

  @name_regex ~r/^[a-zA-Z][a-zA-Z_]*[a-zA-Z]$/
  @name_error "must start and finish with a letter and must contain only letters and underscore"

  @spec validate_name(map, atom | String.t()) :: {:ok, map} | {:error, String.t()}
  def validate_name(input, key \\ :name) do
    with {:ok, name} <- Validator.require_and_extract(input, key),
         :ok <- Validator.validate_length(name, key, min: 2, max: 20),
         :ok <- Validator.validate_match(name, key, @name_regex, @name_error) do
      {:ok, Map.put(input, key, String.downcase(name))}
    end
  end

  @spec validate_hostname(map, atom | String.t()) :: {:ok, map} | {:error, String.t()}
  def validate_hostname(input, _key \\ nil) do
    with {:ok, hostname} <- Validator.require_and_extract(input, :hostname),
         :ok <- Validator.validate_hostname(hostname, :hostname) do
      {:ok, input}
    end
  end

  @spec validate_port(map, atom | String.t()) :: {:ok, map} | {:error, String.t()}
  def validate_port(input, _key \\ nil) do
    with {:ok, port} <- Validator.require_and_extract(input, :port),
         :ok <- Validator.validate_number(port, :port) do
      {:ok, input}
    end
  end

  @spec validate_path(map, atom | String.t()) :: {:ok, map} | {:error, String.t()}
  def validate_path(input, _key \\ nil) do
    with {:ok, path} <- Validator.require_and_extract(input, :path),
         :ok <- Validator.validate_path(path, :path) do
      {:ok, Map.put(input, :path, Path.expand(path))}
    end
  end
end

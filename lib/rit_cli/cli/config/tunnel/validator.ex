defmodule RitCLI.CLI.Config.Tunnel.Validator do
  @moduledoc false

  alias RitCLI.CLI.Input.Validator

  @from_regex ~r/^(local|repo)$/
  @from_error "must be 'local' or 'repo'"

  @spec validate_from(map, atom) :: {:ok, map} | {:error, String.t()}
  def validate_from(input, _key \\ nil) do
    with {:ok, from} <- Validator.require_and_extract(input, :from),
         :ok <- Validator.validate_match(from, :from, @from_regex, @from_error) do
      {:ok, input}
    end
  end

  @name_regex ~r/^[a-zA-Z][a-zA-Z_]*[a-zA-Z]$/
  @name_error "must start and finish with a letter and must contain only letters and underscore"

  @spec validate_name(map, atom) :: {:ok, map} | {:error, String.t()}
  def validate_name(input, key \\ :name) do
    with {:ok, name} <- Validator.require_and_extract(input, key),
         :ok <- Validator.validate_length(name, key, min: 2, max: 20),
         :ok <- Validator.validate_match(name, key, @name_regex, @name_error) do
      {:ok, Map.put(input, key, String.downcase(name))}
    end
  end

  @spec validate_path(map, atom | String.t()) :: {:ok, map} | {:error, String.t()}
  def validate_path(input, _key \\ nil) do
    with {:ok, path} <- Validator.require_and_extract(input, :path),
         :ok <- Validator.validate_path(path, :path) do
      {:ok, Map.put(input, :path, Path.expand(path))}
    end
  end

  @spec validate_reference(map, atom) :: {:ok, map} | {:error, String.t()}
  def validate_reference(input, _key \\ nil) do
    with {:ok, from} <- Validator.require_and_extract(input, :from),
         {:ok, reference} <- Validator.require_and_extract(input, :reference),
         :ok <- validate_reference_from(from, reference) do
      if Map.get(input, :name, "") != "" do
        {:ok, input}
      else
        {:ok, Map.put(input, :name, Enum.at(String.split(reference, "/"), -1))}
      end
    end
  end

  defp validate_reference_from(from, reference) do
    case from do
      "local" -> Validator.validate_path(reference, :reference)
      "repo" -> Validator.validate_hostname(reference, :reference)
    end
  end
end

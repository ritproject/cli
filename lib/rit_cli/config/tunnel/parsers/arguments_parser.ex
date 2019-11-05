defmodule RitCLI.Config.Tunnel.ArgumentsParser do
  @moduledoc false

  alias RitCLI.Utils.InputValidator, as: Validator

  @from_regex ~r/^(local|repo)$/
  @from_error "must be 'local' or 'repo'"

  @spec parse_from(String.t(), atom | String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def parse_from(value, arg \\ :from) do
    with :ok <- Validator.validate_required(value, arg),
         :ok <- Validator.validate_match(value, :from, @from_regex, @from_error) do
      {:ok, value}
    end
  end

  @name_regex ~r/^[a-zA-Z][a-zA-Z_]*[a-zA-Z]$/
  @name_error "must start and finish with a letter and must contain only letters and underscore"

  @spec parse_name(String.t(), atom | String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def parse_name(value, arg \\ :name) do
    with :ok <- Validator.validate_required(value, arg),
         :ok <- Validator.validate_length(value, arg, min: 2, max: 20),
         :ok <- Validator.validate_match(value, arg, @name_regex, @name_error) do
      {:ok, String.downcase(value)}
    end
  end

  @spec parse_path(String.t(), atom | String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def parse_path(value, arg \\ :path) do
    with :ok <- Validator.validate_required(value, arg),
         :ok <- Validator.validate_path(value, arg) do
      {:ok, Path.expand(value)}
    end
  end

  @spec parse_reference(String.t(), String.t(), atom | String.t()) ::
          {:ok, String.t()} | {:error, Error.t()}
  def parse_reference(value, from, arg \\ :reference) do
    case Validator.validate_required(value, arg) do
      :ok -> parse_reference_from(from, value, arg)
      error -> error
    end
  end

  @spec maybe_extract_name_from_reference(String.t(), String.t()) :: String.t()
  def maybe_extract_name_from_reference(name, reference) do
    if name != "" do
      name
    else
      Enum.at(String.split(reference, "/"), -1)
    end
  end

  defp parse_reference_from(from, value, arg) do
    case from do
      "local" ->
        parse_path(value, arg)

      "repo" ->
        case Validator.validate_hostname(value, :reference) do
          :ok -> {:ok, value}
          error -> error
        end
    end
  end
end

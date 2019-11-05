defmodule RitCLI.Utils.InputValidator do
  @moduledoc false

  alias RitCLI.Meta.Error

  @hostname_regex ~r/^http(s)*:\/\/[a-zA-Z0-9][a-zA-Z0-9\.\/\-\_@:]+[a-zA-Z-0-9]$/
  @hostname_error "must be a valid hostname, with http or https prefix and no trailing slash"

  @spec validate_hostname(String.t(), atom | String.t()) :: :ok | {:error, Error.t()}
  def validate_hostname(value, arg) do
    case validate_match(value, arg, @hostname_regex, @hostname_error) do
      :ok -> validate_length(value, arg, max: 150)
      error -> error
    end
  end

  @spec validate_path(String.t(), atom | String.t()) :: :ok | {:error, Error.t()}
  def validate_path(value, arg) do
    if File.exists?(value) do
      :ok
    else
      error(value, arg, "must be a valid path")
    end
  end

  # @spec validate_number(String.t(), atom | String.t()) :: :ok | {:error, Error.t()}
  # def validate_number(value, arg) do
  #   _ = String.to_integer(value)
  #   :ok
  # rescue
  #   _error -> error(value, arg, "must be a number")
  # end

  @spec validate_length(String.t(), atom | String.t(), keyword) :: :ok | {:error, Error.t()}
  def validate_length(value, arg, max: max) do
    if String.length(value) <= max do
      :ok
    else
      error(value, arg, "must have at most %{max_length} characters", max_length: max)
    end
  end

  def validate_length(value, arg, min: min, max: max) do
    value_length = String.length(value)

    if value_length >= min and value_length <= max do
      :ok
    else
      error(
        value,
        arg,
        "must have at least %{min_length} and at most %{max_length} characters",
        min_length: min,
        max_length: max
      )
    end
  end

  @spec validate_match(String.t(), atom | String.t(), Regex.t(), String.t()) ::
          :ok | {:error, Error.t()}
  def validate_match(value, arg, regex, description) do
    if String.match?(value, regex) do
      :ok
    else
      error(value, arg, description)
    end
  end

  @spec validate_required(String.t(), atom | String.t()) :: :ok | {:error, Error.t()}
  def validate_required(value, arg) do
    if value != "" and value != nil do
      :ok
    else
      {
        :error,
        Error.build(
          __MODULE__,
          :argument_required,
          "argument '%{arg}' must not be empty",
          arg: arg
        )
      }
    end
  end

  @spec error(any, atom | String.t(), String.t(), keyword | nil) :: {:error, Error.t()}
  def error(value, arg, description, metadata \\ nil) do
    if metadata do
      {
        :error,
        Error.build(
          __MODULE__,
          :argument_invalid,
          "argument '%{arg}' with value '%{value}' #{description}",
          [arg: arg, value: value] ++ metadata
        )
      }
    else
      {
        :error,
        Error.build(
          __MODULE__,
          :argument_invalid,
          "argument '%{arg}' with value '%{value}' #{description}",
          arg: arg,
          value: value
        )
      }
    end
  end
end

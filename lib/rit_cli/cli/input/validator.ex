defmodule RitCLI.CLI.Input.Validator do
  @moduledoc false

  @hostname_regex ~r/^http(s)*:\/\/[a-zA-Z0-9][a-zA-Z0-9\.\/\-\_]+[a-zA-Z-0-9]$/
  @hostname_error "must be a valid hostname, with http or https prefix and no trailing slash"

  @spec validate_hostname(String.t(), atom | String.t()) :: :ok | {:error, atom, Output.t()}
  def validate_hostname(value, key) do
    case validate_match(value, key, @hostname_regex, @hostname_error) do
      :ok -> validate_length(value, key, max: 150)
      error -> error
    end
  end

  @spec validate_path(String.t(), atom | String.t()) :: :ok | {:error, atom, Output.t()}
  def validate_path(path, key) do
    if File.exists?(path) do
      :ok
    else
      error(path, key, "must be a valid path")
    end
  end

  @spec validate_number(String.t(), atom | String.t()) :: :ok | {:error, atom, Output.t()}
  def validate_number(value, key) do
    _ = String.to_integer(value)
    :ok
  rescue
    _error -> error(value, key, "must be a number")
  end

  # @spec validate_length(String.t, atom | String.t, keyword(number())) ::
  #         :ok | {:error, String.t}
  # def validate_length(value, key, min: min) do
  #   if String.length(value) >= min do
  #     :ok
  #   else
  #     error(value, key, "must have at least #{min} characters")
  #   end
  # end

  @spec validate_length(String.t(), atom | String.t(), keyword) :: :ok | {:error, String.t()}
  def validate_length(value, key, max: max) do
    if String.length(value) <= max do
      :ok
    else
      error(value, key, "must have at most #{max} characters")
    end
  end

  def validate_length(value, key, min: min, max: max) do
    value_length = String.length(value)

    if value_length >= min and value_length <= max do
      :ok
    else
      error(value, key, "must have at least #{min} and at most #{max} characters")
    end
  end

  @spec validate_match(String.t(), atom | String.t(), Regex.t(), String.t()) ::
          :ok | {:error, String.t()}
  def validate_match(value, key, regex, message) do
    if String.match?(value, regex) do
      :ok
    else
      error(value, key, message)
    end
  end

  @spec validate_at_least_one_optional(list(atom | String.t()), list(atom | String.t())) ::
          :ok | {:error, String.t()}
  def validate_at_least_one_optional(optionals_got, optionals_expected) do
    if length(optionals_expected -- optionals_got) == length(optionals_expected) do
      optionals_list =
        optionals_expected
        |> Enum.map(fn optional -> "<#{to_string(optional)}>" end)
        |> Enum.join(", ")

      message = "expects at least one of the optional inputs: #{optionals_list}"
      {:error, message}
    else
      :ok
    end
  end

  @spec optional(map, atom | String.t(), function, list(atom | String.t())) ::
          {:ok, map, list(atom | String.t())} | {:error, String.t()}
  def optional(input, key, function, optionals \\ []) do
    case function.(input, key) do
      {:ok, input} ->
        {:ok, input, [key] ++ optionals}

      {:error, message} ->
        if message =~ "must not be empty" do
          {:ok, input, optionals}
        else
          {:error, message}
        end
    end
  end

  @spec require_and_extract(map, atom | String.t()) :: {:ok, any} | {:error, String.t()}
  def require_and_extract(input, key) do
    value = Map.get(input, key)

    if value != "" and value != nil do
      {:ok, value}
    else
      error("", key, "must not be empty")
    end
  end

  @spec error(any, atom | String.t(), String.t()) :: {:error, String.t()}
  def error(value, key, message) do
    if value == "" do
      {:error, "<#{to_string(key)}> argument #{message}"}
    else
      {:error, "<#{to_string(key)}> argument with value '#{value}' #{message}"}
    end
  end
end

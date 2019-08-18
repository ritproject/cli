defmodule RitCLI.CLI.Config.Server.Validator do
  @moduledoc false

  @name_regex ~r/^[a-zA-Z][a-zA-Z_]*[a-zA-Z]$/
  @name_error "must start and finish with a letter and must contain only letters and underscore"

  @spec validate_name(map(), atom() | binary()) :: {:ok, map()} | {:error, binary()}
  def validate_name(input, key) do
    with {:ok, name} <- require_and_extract(input, key),
         :ok <- validate_length(name, key, min: 2, max: 20),
         :ok <- validate_match(name, key, @name_regex, @name_error) do
      {:ok, Map.put(input, key, String.downcase(name))}
    end
  end

  @hostname_regex ~r/^http(s)*:\/\/[a-zA-Z0-9][a-zA-Z0-9\.\/\-\_]+[a-zA-Z-0-9]$/
  @hostname_error "must be a valid hostname, with http or https prefix and no trailing slash"

  @spec validate_hostname(map(), atom() | binary()) :: {:ok, map()} | {:error, binary()}
  def validate_hostname(input, key) do
    with {:ok, hostname} <- require_and_extract(input, key),
         :ok <- validate_match(hostname, key, @hostname_regex, @hostname_error),
         :ok <- validate_length(hostname, key, max: 150) do
      {:ok, input}
    end
  end

  @spec validate_port(map(), atom() | binary()) :: {:ok, map()} | {:error, binary()}
  def validate_port(input, key) do
    with {:ok, port} <- require_and_extract(input, key),
         :ok <- validate_number(port, key) do
      {:ok, input}
    end
  end

  @spec validate_path(map(), atom() | binary()) :: {:ok, map()} | {:error, binary()}
  def validate_path(input, key) do
    with {:ok, path} <- require_and_extract(input, key) do
      if File.exists?(path) do
        {:ok, Map.put(input, key, Path.expand(path))}
      else
        error(path, key, "must be a valid path")
      end
    end
  end

  @spec validate_number(binary(), atom() | binary()) :: :ok | {:error, binary()}
  def validate_number(value, key) do
    _ = String.to_integer(value)
    :ok
  rescue
    _error -> error(value, key, "must be a number")
  end

  # @spec validate_length(binary(), atom() | binary(), keyword(number())) ::
  #         :ok | {:error, binary()}
  # def validate_length(value, key, min: min) do
  #   if String.length(value) >= min do
  #     :ok
  #   else
  #     error(value, key, "must have at least #{min} characters")
  #   end
  # end

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

  @spec validate_match(binary(), atom() | binary(), Regex.t(), binary()) ::
          :ok | {:error, binary()}
  def validate_match(value, key, regex, message) do
    if String.match?(value, regex) do
      :ok
    else
      error(value, key, message)
    end
  end

  @spec validate_at_least_one_optional([atom() | binary()], [atom() | binary()]) ::
          :ok | {:error, binary()}
  def validate_at_least_one_optional(optionals_got, optionals_expected) do
    if length(optionals_expected -- optionals_got) == length(optionals_expected) do
      optionals_list =
        optionals_expected
        |> Enum.map(fn optional -> "<server_#{to_string(optional)}>" end)
        |> Enum.join(", ")

      message = "expects at least one of the optional inputs: #{optionals_list}"
      {:error, message}
    else
      :ok
    end
  end

  @spec optional(map(), atom() | binary(), function(), [atom() | binary()]) ::
          {:ok, map(), [atom() | binary()]} | {:error, binary()}
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

  defp require_and_extract(input, key) do
    value = Map.get(input, key)

    if value != "" do
      {:ok, value}
    else
      error("", key, "must not be empty")
    end
  end

  defp error(value, key, message) do
    if value == "" do
      {:error, "<server_#{to_string(key)}> argument #{message}"}
    else
      {:error, "<server_#{to_string(key)}> argument with value '#{value}' #{message}"}
    end
  end
end

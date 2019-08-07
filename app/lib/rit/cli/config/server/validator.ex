defmodule Rit.CLI.Config.ServerValidator do
  @moduledoc false

  def validate(data, :show_server) do
    validate_name data, :name
  end

  def validate(data, :add_server) do
    with {:ok, data} <- validate_name(data, :name),
         {:ok, data} <- validate_hostname(data, :hostname) do
      validate_port data, :port
    end
  end

  def validate(data, :edit_server) do
    with {:ok, data} <- validate_name(data, :current_name),
         {:ok, data, optionals} <- optional(data, :name, &validate_name/2),
         {:ok, data, optionals} <- optional(data, :hostname, &validate_hostname/2, optionals),
         {:ok, data, optionals} <- optional(data, :port, &validate_port/2, optionals),
         :ok <- validate_at_least_one_optional(optionals, [:name, :hostname, :port]) do
      {:ok, data}
    else
      error -> error
    end
  end

  def validate(data, :remove_server) do
    validate_name data, :name
  end

  def validate(data, :set_default_server) do
    case validate_name data, :name do
      {:ok, %{path: path} = data} -> if path, do: validate_path(data, :path), else: {:ok, data}
      error -> error
    end
  end

  def validate(%{path: path} = data, :unset_default_server) do
    if path do
      validate_path data, :path
    else
      {:ok, data}
    end
  end

  @name_regex ~r/^[a-zA-Z][a-zA-Z_]*[a-zA-Z]$/
  @name_error "must start and finish with a letter and must contain only letters and underscore"

  defp validate_name(data, key) do
    with {:ok, name} <- require_and_extract(data, key),
         :ok <- validate_match(name, key, @name_regex, @name_error),
         :ok <- validate_length(name, key, min: 2, max: 20) do
      {:ok, Map.put(data, key, String.downcase(name) |> String.to_atom())}
    end
  end

  @hostname_regex ~r/^http(s)*:\/\/[a-zA-Z0-9][a-zA-Z0-9\.\/]+[a-zA-Z-0-9]$/
  @hostname_error "must be a valid hostname, with http or https prefix and no trailing slash"

  defp validate_hostname(data, key) do
    with {:ok, hostname} <- require_and_extract(data, key),
         :ok <- validate_match(hostname, key, @hostname_regex, @hostname_error),
         :ok <- validate_length(hostname, key, max: 150) do
      {:ok, data}
    end
  end

  defp validate_port(data, key) do
    with {:ok, port} <- require_and_extract(data, key),
         :ok <- validate_number(port, key) do
      {:ok, Map.put(data, key, String.to_integer(port))}
    end
  end

  defp validate_path(data, key) do
    with {:ok, path} <- require_and_extract(data, key) do
      if File.exists? path do
        {:ok, Map.put(data, key, String.to_atom(Path.expand(path)))}
      else
        error path, key, "must be a valid path"
      end
    end
  end

  defp validate_number(value, key) do
    _ = String.to_integer value
    :ok
  rescue
    _error -> error value, key, "must be a number"
  end

  defp validate_length(value, key, min: min) do
    if String.length(value) >= min do
      :ok
    else
      error value, key, "must have at least #{min} characters"
    end
  end

  defp validate_length(value, key, max: max) do
    if String.length(value) <= max do
      :ok
    else
      error value, key, "must have at most #{max} characters"
    end
  end

  defp validate_length(value, key, min: min, max: max) do
    value_length = String.length(value)
    if value_length >= min and value_length <= max do
      :ok
    else
      error value, key, "must have at least #{min} and at most #{max} characters"
    end
  end

  defp validate_match(value, key, regex, message) do
    if String.match? value, regex do
      :ok
    else
      error value, key, message
    end
  end

  defp validate_at_least_one_optional(optionals_got, optionals_expected) do
    if length(optionals_expected -- optionals_got) == length(optionals_expected) do
      optionals_list =
        optionals_expected
        |> Enum.map(fn optional -> "<server_#{to_string optional}>" end)
        |> Enum.join(", ")

      message = "Expects at least one of the optional inputs: #{optionals_list}"
      {:error, :invalid_input, message}
    else
      :ok
    end
  end

  defp require_and_extract(data, key) do
    if Map.has_key? data, key do
      value = data[key]

      if value != "" do
        {:ok, value}
      else
        error "", key, "must not be empty"
      end
    else
      error "", key, "must not be blank"
    end
  end

  defp optional(data, key, function, optionals \\ []) do
    if Map.has_key? data, key do
      case function.(data, key) do
        {:ok, data} -> {:ok, data, [key] ++ optionals}
        error -> error
      end
    else
      {:ok, data, optionals}
    end
  end

  defp error(value, key, message) do
    complete_message = "<server_#{to_string key}> argument #{message}."
    if value == "" do
      {:error, :invalid_input, complete_message}
    else
      {:error, :invalid_input, value, complete_message}
    end
  end
end

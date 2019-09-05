defmodule RitCLI.CLI.Error do
  @moduledoc false

  alias RitCLI.CLI.Output

  @tunnel_fetcher_config_undefined """
  Tunnel failed to find config with name '{name}'
  """

  @tunnel_fetcher_default_not_set """
  Tunnel failed to find default config
  """

  @tunnel_fetcher_local_reference_fetch_failed """
  Tunnel failed to fetch local reference '{name}' data on path '{path}'
  """

  @tunnel_fetcher_local_reference_undefined """
  Tunnel local reference '{name}' on path '{path}' does not exist
  """

  @tunnel_fetcher_repo_fetch_failed """
  Tunnel failed to fetch data from repo '{name}' with link '{link}'
  """

  @tunnel_runner_link_dir_undefined """
  Tunnel failed to identify 'link_dir' on settings
  """

  @tunnel_runner_ln_s_failed """
  Tunnel failed to create symbolic link
  """

  @tunnel_runner_operation_failed """
  Tunnel operation '{operation}' failed, exit code: {code}
  """

  @tunnel_runner_operation_undefined """
  Tunnel failed to identify operation to perform on settings
  """

  @tunnel_runner_root_run_undefined """
  Tunnel failed to identify run on settings
  """

  @tunnel_settings_invalid_yaml """
  Tunnel failed to parse YAML file
  """

  @tunnel_settings_not_found """
  Tunnel failed find tunnel YAML file
  """

  @messages %{
    tunnel_fetcher: %{
      config_undefined: @tunnel_fetcher_config_undefined,
      default_not_set: @tunnel_fetcher_default_not_set,
      local_reference_fetch_failed: @tunnel_fetcher_local_reference_fetch_failed,
      local_reference_undefined: @tunnel_fetcher_local_reference_undefined,
      repo_fetch_failed: @tunnel_fetcher_repo_fetch_failed
    },
    tunnel_runner: %{
      link_dir_undefined: @tunnel_runner_link_dir_undefined,
      ln_s_failed: @tunnel_runner_ln_s_failed,
      operation_failed: @tunnel_runner_operation_failed,
      operation_undefined: @tunnel_runner_operation_undefined,
      root_run_undefined: @tunnel_runner_root_run_undefined
    },
    tunnel_settings: %{
      invalid_yaml: @tunnel_settings_invalid_yaml,
      not_found: @tunnel_settings_not_found
    }
  }

  @spec build_error(atom, atom, keyword) :: {:error, atom, Output.t()}
  def build_error(module_id, error_id, data \\ []) do
    message =
      @messages
      |> Map.get(module_id, %{})
      |> Map.get(error_id, "")
      |> fetch_data(data)

    {:error, error_id, build_output(message, data)}
  end

  defp fetch_data(message, data) do
    Enum.reduce(data, message, &fetch_item/2)
  end

  defp fetch_item({key, value}, message) do
    String.replace(message, "{#{key}}", to_string(value))
  end

  defp build_output(message, data) do
    %Output{}
    |> struct(error: message)
    |> maybe_add_code(data)
  end

  defp maybe_add_code(%Output{} = output, data) do
    case Keyword.get(data, :code) do
      nil -> output
      code -> struct(output, code: code)
    end
  end
end

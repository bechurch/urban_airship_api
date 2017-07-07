defmodule UrbanAirshipAPI do
  @moduledoc """
  AN HTTPoison module for making requests to the Urban Airship API
  """
  use HTTPoison.Base

  @endpoint "https://go.urbanairship.com/api/"

  @ua_master  Application.get_env(:urban_airship)[:master]
  @ua_key     Application.get_env(:urban_airship)[:key]
  @ua_version Application.get_env(:urban_airship)[:version]

  @default_push_options [badge: 0, device_types: "all", sound: "default"]

  def post_headers do
    [
      {"Accept", "application/vnd.urbanairship+json; version=#{@ua_version};"},
      {"Content-Type", "application/json"}
    ]
  end

  # Urban Airship API Wrappers 🚀
  # =============================

  @doc """
  Push a given message to a device
  """
  @spec push!(String.t(), String.t()) :: String.t()
  def push!(device_token, message, options \\ []) do
    %{
      badge: badge,
      device_types: device_types,
      sound: sound
    } = apply_default_push_options(options)

    message_object = %{
      "audience": %{
          "device_token": device_token
      },
      "notification": %{
          "alert": message,
          "ios": %{
            "badge": badge,
            "sound": sound
          }
      },
      "device_types": device_types
    }

    {:ok, response} = post("push", JSON.encode!(message_object))

    response
    |> Map.get(:body)
    |> JSON.decode!()
  end

  # HTTPoison callbacks 💀
  # ======================

  @doc """
  Set the Basic Authentication header
  """
  @spec process_request_options(keyword) :: keyword
  def process_request_options(options), do: options ++ [hackney: [basic_auth: {@ua_key, @ua_master}]]

  @doc """
  Append the default headers to the request
  """
  @spec process_request_headers(term) :: [{String.t(), term}]
  def process_request_headers(headers), do: headers ++ post_headers()

  @doc """
  Prepend the base API endpoint to the requested URL
  """
  @spec process_url(String.t()) :: String.t()
  def process_url(url), do: @endpoint <> url

  # Utilities 🛠
  # ============

  @doc """
  Apply default options for push requests
  """
  @spec apply_default_push_options([keyword()]) :: map()
  def apply_default_push_options(options), do: Enum.into(Keyword.merge(default_push_options, options), %{})
end

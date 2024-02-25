defmodule BotWeb.Api.AuthController do
  use BotWeb, :controller
  require Logger

  def has_credentials(conn, _params) do
    try do
      json(conn, %{
        has_credentials: Enum.count(Bot.Mastodon.Auth.PersistCredentials.get_all()) > 0
      })
    catch
      _ ->
        json(conn, %{has_credentials: false})
    end
  end

  @spec connect_application(Plug.Conn.t(), any) :: Plug.Conn.t()
  def connect_application(conn, params) do
    creds =
      Bot.Mastodon.Auth.ApplicationCredentials.setup_credentials(Map.get(params, "fedi_url"))

    case creds do
      {:ok, credentials} ->
        json(conn, credentials)

      {:error, reason} ->
        json(conn, %{error: reason})
    end
  end

  @spec connect_user(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def connect_user(conn, params) do
    user_code = Map.get(params, "user_code")

    credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
    response =
      Bot.Mastodon.Auth.UserCredentials.authorize_bot_to_user(
        credentials.client_id,
        credentials.client_secret,
        credentials.app_token,
        user_code
      )

    case response do
      {:ok, result} ->
        json(conn, result)

      {:error, reason} ->
        json(conn, "Could not fetch token: #{reason}")
    end
  end

  @spec get_token(Plug.Conn.t(), any) :: Plug.Conn.t()
  def get_token(conn, _params) do
    credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
    token = credentials.user_token
    json(conn, token)
  end

  def delete_bot_credentials(conn, _params) do
    Bot.Mastodon.Auth.PersistCredentials.delete_all()

    send_resp(conn, :no_content, "")
  end
end

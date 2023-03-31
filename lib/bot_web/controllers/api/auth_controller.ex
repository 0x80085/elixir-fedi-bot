defmodule BotWeb.AuthController do
  use BotWeb, :controller

  @spec connect_application(Plug.Conn.t(), any) :: Plug.Conn.t()
  def connect_application(conn, _params) do
    creds = Bot.Mastodon.Auth.ApplicationCredentials.setup_credentials()

    case creds do
      {:ok, credentials} ->
        json(conn, credentials)

      {:error, reason} ->
        json(conn, %{error: reason})
    end
  end

  def connect_user(conn, params) do
    user_code = Map.get(params, "user_code")
    IO.puts("user_code")
    IO.puts(user_code)

    response =
      Bot.Mastodon.Auth.UserCredentials.authorize_bot_to_user(
        Bot.Mastodon.Auth.ApplicationCredentials.get_client_id(),
        Bot.Mastodon.Auth.ApplicationCredentials.get_client_secret(),
        Bot.Mastodon.Auth.ApplicationCredentials.get_token(),
        user_code
      )

    case response do
      {:ok, result} ->
        json(conn, result)

      {:error, reason} ->
        json(conn, "Could not fetch token: #{reason}")
    end
  end

  @spec post_status(Plug.Conn.t(), map) :: Plug.Conn.t()
  def post_status(conn, params) do
    action =
      Bot.Mastodon.Actions.PostStatus.post(
        Map.get(params, "text"),
        Bot.Mastodon.Auth.UserCredentials.get_token()
      )

    case action do
      {:ok, _} ->
        json(conn, "status posted ")

      {:error, reason} ->
        json(conn, "Could not post status: #{reason}")
    end
  end

  @spec get_token(Plug.Conn.t(), any) :: Plug.Conn.t()
  def get_token(conn, _params) do
    token = Bot.Mastodon.Auth.ApplicationCredentials.get_token()
    json(conn, token)
  end

end

defmodule BotWeb.Api.ActionsController do
  use BotWeb, :controller

  @spec post_status(Plug.Conn.t(), map) :: Plug.Conn.t()
  def post_status(conn, params) do
    action =
      Bot.Mastodon.Actions.PostStatus.post(
        %{
          hashtags: "",
          text: Map.get(params, "text"),
          media: Map.get(params, "media_url"),
          id: ""
        },
        Bot.Mastodon.Auth.PersistCredentials.get_credentials().user_token
      )

    case action do
      {:ok, _} ->
        json(conn, "status posted ")

      {:error, reason} ->
        IO.inspect(reason)
        send_resp(conn, :internal_server_error, Jason.encode!(%{message: reason}))
    end
  end

  @spec preview_status(Plug.Conn.t(), map) :: Plug.Conn.t()
  def preview_status(conn, _params) do
    send_file(conn, 200, "priv/static/templates/toot.html")
  end
end

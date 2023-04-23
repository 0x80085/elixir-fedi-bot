defmodule BotWeb.Api.ActionsController do
  use BotWeb, :controller

  @spec post_status(Plug.Conn.t(), map) :: Plug.Conn.t()
  def post_status(conn, params) do
    action =
      Bot.Mastodon.Actions.PostStatus.post(
        %{
          text: Map.get(params, "text"),
          media: [],
          id: Map.get(params, "text")
          },
        Bot.Mastodon.Auth.UserCredentials.get_token(),
        false
      )

    case action do
      {:ok, _} ->
        json(conn, "status posted ")

      {:error, reason} ->
        json(conn, "Could not post status: #{reason}")
    end
  end
end

defmodule BotWeb.Api.TestController do
  use BotWeb, :controller
  require Logger
  @spec test_rss_route(Plug.Conn.t(), any) :: Plug.Conn.t()
  def test_rss_route(conn, params) do
    case get_rss_url(params) do
      {:ok, url} ->
        case Bot.RSS.RssFetcher.get_entries(url) do
          {:ok, entries} ->
            Logger.debug("parsed, try send to client")

            try do
              json(conn, entries)
            catch
              value ->
                Logger.error("Caught #{inspect(value)}")
                Logger.error("parse failed")
                json(conn, "Can't encode RSS to JSON:  #{inspect(value)}")
            end

          {:error, reason} ->
            json(conn, %{error: reason})
        end

      {:error, reason} ->
        json(conn, %{error: reason})
    end
  end

  def get_rss_url(params) do
    url = Map.get(params, "url")

    case url == "" || url == nil || !String.starts_with?(url, ["https://"]) do
      false -> {:ok, url}
      true -> {:error, "no RSS URL found"}
    end
  end
end

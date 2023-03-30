defmodule BotWeb.TestController do
  use BotWeb, :controller

  @spec testRssRoute(Plug.Conn.t(), any) :: Plug.Conn.t()
  def testRssRoute(conn, params) do
    case get_rss_url(params) do
      {:ok, url} ->
        case Bot.RSS.RssFetcher.get_entries(url) do
          {:entries, entries} ->
            IO.puts("parsed, try send to client")

            try do
              json(conn, entries)
            catch
              value ->
                IO.puts("Caught #{inspect(value)}")
                IO.puts("parse failed")
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

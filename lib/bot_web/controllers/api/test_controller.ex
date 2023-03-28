defmodule BotWeb.TestController do
  use BotWeb, :controller

  @spec testRoute(Plug.Conn.t(), any) :: Plug.Conn.t()
  def testRoute(conn, params) do
    url = Map.get(params, "url")

    if url == "" || url == nil || !String.starts_with?(url, ["https://"]) do
      json(conn, "No URL passed")
    end

    IO.puts("found url:")
    IO.puts(url)

    result = get_entries(url)

    case result do
      {:entries, entries} ->
        # IO.puts(entries)
        IO.puts("parsed, try send to client")

        try do
          json(conn, entries)
        catch
          value ->
            IO.puts("Caught #{inspect(value)}")
            IO.puts("parse failed")
            json(conn, "Can't encode RSS to JSON  #{inspect(value)}")
        end

      {:error, reason} ->
        json(conn, reason)
    end
  end

  def get_entries(rss_url) do
    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        parse_result = try_parse_rss(body)

        case parse_result do
          {:ok, feed} ->
            parsedEntries =
              Enum.map(feed.entries, fn it ->
                %{id: it.id,link: it.link, title: it.title}
              end)

            {:entries, parsedEntries}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @spec try_parse_rss(binary) :: {:ok, FeederEx.Feed} | {:error, String.t()}
  defp try_parse_rss(data) do
    result =
      try do
        FeederEx.parse(data)
      rescue
        _ in BadMapError -> {:error, "Can't parse RSS (possible non-RSS data)"}
      end

    case result do
      {:ok, feed, _} -> {:ok, feed}
      {:error, reason} -> {:error, reason}
    end
  end
end

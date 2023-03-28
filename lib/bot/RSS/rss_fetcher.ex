defmodule Bot.RSS.RssFetcher do

  def get_entries(rss_url) do
    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        parse_response(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def parse_response(body) do
    parse_result = try_parse_rss(body)

    case parse_result do
      {:ok, feed} ->
        parsedEntries =
          Enum.map(feed.entries, fn it ->
            %{id: it.id, link: it.link, title: it.title, updated: it.updated}
          end)

        {:entries, parsedEntries}

      {:error, reason} ->
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

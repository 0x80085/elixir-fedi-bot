defmodule Bot.RSS.RssFetcher do
  @spec get_entries(binary) :: {:error, any} | {:ok, list}
  def get_entries(rss_url) do
    IO.puts("get_entries for #{rss_url}")
    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.puts("OK #{rss_url} parsing results")
        parse_response(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("FAIL for #{rss_url}")
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

        {:ok, parsedEntries}

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

    case result do #  no case clause matching: {:fatal_error, :function_clause}
      {:ok, feed, _} -> {:ok, feed} # why the ", _}" ?
      {:error, reason} -> {:error, reason}
    end
  end
end

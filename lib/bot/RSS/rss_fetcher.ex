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
            %{
              id: it.id,
              link: it.link,
              title: it.title,
              # summary: it.summary,
              # image: it.image,
              updated: it.updated,
              media: get_media(it)
            }
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
        _ -> {:error, "Can't parse RSS (possible non-RSS data)"}
      end

    case result do
      # why the ", _}" vv ?
      {:ok, feed, _} -> {:ok, feed}
      {:error, reason} -> {:error, reason}
      {:fatal_error, _} -> {:error, "fatal error"}
    end
  end

  defp get_media(it) do
    enclosure = get_enclosure(it)
    img_src_list = get_img_src_from_summary(it)

    IO.puts(enclosure || img_src_list)

    enclosure || img_src_list
  end

  defp get_enclosure(it) do
    case it.enclosure do
      nil ->
        nil

      _ ->
        it.enclosure.url
    end
  end

  defp get_img_src_from_summary(it) do
    case it.summary do
      nil ->
        nil

      _ ->
        img_src_regex = ~r/src\s*=\s*"(.+?)"/

        img_tags = Regex.scan(img_src_regex, it.summary)

        IO.puts("Found img sources = #{img_tags}")

        case length(img_tags) == 0 do
          true ->
            nil

          _ ->
            img_tags
        end
    end
  end
end

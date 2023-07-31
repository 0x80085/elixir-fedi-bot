defmodule Bot.RSS.RssFetcher do
  use Timex

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
              summary: it.summary,
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

  def filter_by_newest(entries) do
    now = DateTime.utc_now()
    one_hour_in_s = 3600

    Enum.filter(entries, fn it ->
      parsed_time = parse_time_string(it.updated)

      if parsed_time,
        do: DateTime.diff(now, parsed_time, :second) < one_hour_in_s,
        else: false
    end)
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
      {:fatal_error, reason} -> {:error, reason}
    end
  end

  defp get_media(it) do
    enclosure = get_enclosure(it)
    img_src_list = get_img_src_from_summary(it)
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
        regex = ~r/<img.*?src="(.+?)".*?>/s

        img_tags =
          Enum.map(
            Regex.scan(regex, it.summary),
            fn [_, src] ->
              IO.puts("Found img source = #{src}")
              src
            end
          )

        case length(img_tags) == 0 do
          true ->
            nil

          _ ->
            img_tags
        end
    end
  end

  defp parse_time_string(value) do
    case Timex.parse(value, "{ISO:Extended:Z}") do
      {:ok, updatedTime} ->
        updatedTime

      {:error, _} ->
        # IO.inspect(error)
        # IO.puts("Could not parse as ISO Extended #{value}")

        case Timex.parse(value, "{RFC1123}") do
          {:ok, parsedTime} ->
            # IO.puts("ok parsed as {RFC1123}")
            # IO.inspect(parsedTime)
            parsedTime

          {:error, error} ->
            IO.inspect(error)
            IO.puts("Could not parse #{value} at all")
            nil
        end
    end
  end
end

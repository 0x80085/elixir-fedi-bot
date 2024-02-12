defmodule Bot.RSS.RssFetcher do
  alias Bot.RSS.FoundUrlArchive
  use Timex
  use Ecto.Schema
  import Ecto.Query
  require Logger

  @spec get_entries(binary) :: {:error, any} | {:ok, list}
  def get_entries(rss_url) do
    msg = "Checking #{rss_url}"
    Logger.info(msg)
    Bot.Events.add_event(Bot.Events.new_event(msg, "Info"))

    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        content_type =
          headers
          |> Enum.find(fn {key, _value} -> String.downcase(key) == "content-type" end)
          |> Tuple.to_list()
          |> Enum.at(1)

        IO.inspect("content_type")
        IO.inspect(content_type)

        if String.contains?(String.downcase(content_type), "application/rss+xml") ||
             String.contains?(String.downcase(content_type), "text/xml") do
          Logger.info("OK #{rss_url} parsing results")
          parse_response(body)
        else
          msg = "The response from #{rss_url} is not XML or doesn't conform to the RSS standard"
          Logger.warn(msg)
          {:error, msg}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        msg =
          "The request to #{rss_url} was successful, but the response body is empty or the received status code (which is #{status_code}) is not 200"

        Logger.warn(msg)
        {:error, msg}

      {:error, reason} ->
        Logger.error("Error fetching #{rss_url}: #{inspect(reason)}")
        {:error, "Error fetching #{rss_url}: #{inspect(reason)}"}
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

    query = from(u in Bot.Settings, select: u, where: u.key == "rss_scrape_max_age_in_s")

    results = Bot.Repo.all(query)

    max_age_in_s =
      case length(results) > 0 do
        true ->
          Enum.at(results, 0).value
          |> String.to_integer()

        _ ->
          one_hour_in_s
      end

    Enum.filter(entries, fn it ->
      parsed_time = parse_time_string(it.updated)

      if parsed_time,
        do: DateTime.diff(now, parsed_time, :second) < max_age_in_s,
        else: false
    end)
    |> Enum.filter(fn it -> !FoundUrlArchive.exists(it.id) end)
  end

  @spec try_parse_rss(binary) :: {:ok, FeederEx.Feed} | {:error, String.t()}
  defp try_parse_rss(data) do
    result =
      try do
        FeederEx.parse(data)
      catch
        _ ->
          {:error, "Can't parse RSS (possible non-RSS data)"}
      end

    case result do
      {:ok, feed, _} -> {:ok, feed}
      {_, _} -> {:error, "Can't parse RSS (possible non-RSS data) #{data}"}
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
              Logger.info("Found img source = #{src}")
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
        case Timex.parse(value, "{RFC1123}") do
          {:ok, parsedTime} ->
            parsedTime

          {:error, error} ->
            IO.inspect(error)
            Logger.warn("Could not parse #{value} at all")
            nil
        end
    end
  end
end

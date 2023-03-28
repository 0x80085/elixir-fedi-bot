defmodule FeederTest do
  @moduledoc"""
  Handles the retrieval and minimal parsing of RSS feeds, using FeederEx.
  """
  alias TLRSS.Item
  use FeederEx

  @spec try_parse_rss(binary) :: {:ok, FeederEx.Feed} | {:error, String.t}
  defp try_parse_rss(data) do
    result = try do
               FeederEx.parse(data)
             rescue
               _ in BadMapError -> {:error,
                                   "Can't parse RSS (possible non-RSS data)"}
             end

    case result do
      {:ok, feed, _} -> {:ok, feed}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_entries(String.t) :: [FeederEx.Entry.t]
  @doc"""
  Fetches the specified RSS feed and returns all entries from it.
  Will return {:error, reason} upon error and {:entries, [entry]} upon
  success.
  The error reason will be unpacked before returning it, meaning it can be
  handled without consideration of %HTTPoison.Error{}.
  """
  def get_entries(rss_url \\ Application.get_env(:tlrss, :rss_url)) do
    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])
    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        parse_result = try_parse_rss(body)
        case parse_result do
          {:ok, feed} ->
            {:entries, feed.entries}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @spec entry_to_item(FeederEx.Entry.t) :: Item.t
  @doc"Converts a %FeederEx.Entry{} to an %Item{}"
  def entry_to_item(%FeederEx.Entry{title: name, id: id, link: link}) do
    %Item{name: name, id: id, link: link}
  end
end

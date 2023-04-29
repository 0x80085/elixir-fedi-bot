defmodule BotWeb.Api.RssController do
  use BotWeb, :controller

  def get_rss_urls(conn, _params) do
    json(conn, Bot.RSS.RssUrlsStore.get_urls())
  end

  def add_url(conn, params) do
    json(conn, Bot.RSS.RssUrlsStore.add( params["url"]))
  end
end

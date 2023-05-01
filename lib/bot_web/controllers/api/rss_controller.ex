defmodule BotWeb.Api.RssController do
  use BotWeb, :controller

  def get_rss_urls(conn, _params) do
    json(conn, Bot.RSS.RssUrlsStore.get_urls())
  end

  def add_url(conn, params) do
    json(conn, Bot.RSS.RssUrlsStore.add( params["url"]))
  end

  def trigger_fetch_job_and_print(conn, params) do
    Bot.RSS.Cron.start_manually()

    json(conn, Bot.RSS.RssUrlsStore.add( params["url"]))
  end

  # def trigger_fetch_job_and_post(conn, params) do
  #   json(conn, Bot.RSS.RssUrlsStore.add( params["url"]))
  # end
end

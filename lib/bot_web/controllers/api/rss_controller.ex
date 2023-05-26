defmodule BotWeb.Api.RssController do
  use BotWeb, :controller

  def get_rss_urls(conn, _params) do
    json(conn, Bot.RSS.RssUrlsStore.get_urls())
  end

  def add_url(conn, params) do
    json(conn, Bot.RSS.RssUrlsStore.add(params["url"]))
  end

  def trigger_fetch_job_and_print(conn, _params) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    Task.Supervisor.start_child(supervisor, fn ->
      IO.puts("Bot.RSS.Cron.start_manuallyf from RssController")
      Bot.RSS.Cron.start_manually()
    end)

    send_resp(conn, :no_content, "")
  end

  # def trigger_fetch_job_and_post(conn, params) do
  #   json(conn, Bot.RSS.RssUrlsStore.add( params["url"]))
  # end
end

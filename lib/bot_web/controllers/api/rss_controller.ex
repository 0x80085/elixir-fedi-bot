defmodule BotWeb.Api.RssController do
  alias BotWeb.Api.RssSettings
  use BotWeb, :controller
  use Ecto.Schema
  import Ecto.Query
  require Logger

  def get_rss_urls(conn, _params) do
    query = from(u in Bot.RssRepo, select: u)

    results = Bot.Repo.all(query)

    sort_asc = fn map1, map2 ->
      map1["url"] < map2["url"]
    end

    urls =
      Enum.map(results, fn it ->
        %{
          "url" => it.url,
          "is_enabled" => it.is_enabled,
          "hashtags" => it.hashtags
        }
      end)
      |> Enum.sort(sort_asc)

    json(conn, urls)
  end

  def add_url(conn, params) do
    entry = %Bot.RssRepo{is_enabled: true, url: params["url"]}

    Bot.Repo.insert(entry)

    send_resp(conn, :created, "OK")
  end

  def patch_rss_url(conn, params) do
    target_url = params["url"]
    is_enabled = params["is_enabled"]
    hashtags = params["hashtags"]

    IO.inspect(target_url)
    IO.inspect(is_enabled)
    IO.inspect(hashtags)

    huh = from(p in Bot.RssRepo, where: p.url == ^target_url)
    IO.inspect(huh)

    huh
    |> Bot.Repo.update_all(set: [is_enabled: is_enabled, hashtags: hashtags])

    send_resp(conn, :no_content, "")
  end

  def trigger_fetch_job_and_print(conn, _params) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    Task.Supervisor.start_child(supervisor, fn ->
      Logger.info("Bot.RSS.Cron.start_manually from RssController")
      Bot.RSS.Cron.start_manually()
    end)

    send_resp(conn, :no_content, "")
  end

  def set_is_dry_run(conn, params) do
    cond do
      params["is_dry_run"] == "true" || params["is_dry_run"] == "false" ->
        RssSettings.set_is_dry_run(params["is_dry_run"])
        send_resp(conn, :no_content, "")

      true ->
        send_resp(conn, :bad_request, "Provide boolean value")
    end
  end

  def get_is_dry_run(conn, _params) do
    json(conn, RssSettings.get_is_dry_run())
  end

  def get_scrape_interval(conn, _params) do
    json(conn, RssSettings.get_scrape_interval())
  end

  def set_scrape_interval(conn, params) do
    RssSettings.set_scrape_interval(params["rss_scrape_interval_in_ms"])
    send_resp(conn, :ok, "OK")
  end

  def get_scrape_max_age(conn, _params) do
    json(conn, RssSettings.get_scrape_max_age())
  end

  def set_scrape_max_age(conn, params) do
    RssSettings.set_scrape_max_age(params["rss_scrape_max_age_in_s"])
    send_resp(conn, :ok, "OK")
  end

  def get_max_post_burst_amount(conn, _params) do
    json(conn, RssSettings.get_max_post_burst_amount())
  end

  def set_max_post_burst_amount(conn, params) do
    RssSettings.set_max_post_burst_amount(params["max_post_burst_amount"])
    send_resp(conn, :ok, "OK")
  end

  def get_events(conn, _params) do
    json(conn, Bot.Events.get_events())
  end
end

defmodule BotWeb.Api.RssController do
  use BotWeb, :controller
  use Ecto.Schema
  import Ecto.Query

  def get_rss_urls(conn, _params) do
    query = from(u in Bot.RssRepo, select: u)

    results = Bot.Repo.all(query)

    IO.inspect(results)

    urls =
      Enum.map(results, fn it ->
        it.url
      end)

    json(conn, urls)
  end

  def add_url(conn, params) do
    entry = %Bot.RssRepo{is_enabled: true, url: params["url"]}

    Bot.Repo.insert(entry)

    send_resp(conn, :created, "OK")
  end

  def trigger_fetch_job_and_print(conn, _params) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    Task.Supervisor.start_child(supervisor, fn ->
      IO.puts("Bot.RSS.Cron.start_manuallyf from RssController")
      Bot.RSS.Cron.start_manually()
    end)

    send_resp(conn, :no_content, "")
  end

  def set_is_dry_run(conn, params) do
    cond do
      params["is_dry_run"] == "true" || params["is_dry_run"] == "false" ->
        case params["is_dry_run"] do
          "true" ->
            Bot.RSS.Cron.set_is_dry_run(true)
            send_resp(conn, :no_content, "")

          "false" ->
            Bot.RSS.Cron.set_is_dry_run(false)
            send_resp(conn, :no_content, "")
        end

      true ->
        send_resp(conn, :bad_request, "Provide boolean value")
    end
  end

  def get_is_dry_run(conn, _params) do
    result = Bot.RSS.Cron.get_is_dry_run()
    IO.inspect(result)

    case result do
      {:ok, res} ->
        json(conn, res)

      _ ->
        send_resp(conn, :internal_error, "")
    end
  end
end

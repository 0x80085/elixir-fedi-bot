defmodule BotWeb.Api.RssSettings do
  use Ecto.Schema
  import Ecto.Query
  require Logger

  def get_scrape_interval() do
    setting = get_scrape_interval_setting()

    # 2 minutes
    setting || 60000 * 2
  end

  def set_scrape_interval(interval) do
    case get_scrape_interval_setting() do
      nil ->
        entry = %Bot.Settings{
          key: "rss_scrape_interval_in_ms",
          value: interval
        }

        Bot.Repo.insert(entry)

      _ ->
        from(p in Bot.Settings, where: p.key == "rss_scrape_interval_in_ms")
        |> Bot.Repo.update_all(set: [value: interval])
    end
  end

  defp get_scrape_interval_setting do
    query = from(u in Bot.Settings, select: u, where: u.key == "rss_scrape_interval_in_ms")

    results = Bot.Repo.all(query)

    case length(results) > 0 do
      true ->
        Enum.at(results, 0).value

      _ ->
        nil
    end
  end

  def get_scrape_max_age() do
    setting = get_scrape_max_age_setting()

    # one hour
    setting || 3600
  end

  def set_scrape_max_age(max_age_in_s) do
    case get_scrape_max_age_setting() do
      nil ->
        entry = %Bot.Settings{
          key: "rss_scrape_max_age_in_s",
          value: max_age_in_s
        }

        Bot.Repo.insert(entry)

      _ ->
        from(p in Bot.Settings, where: p.key == "rss_scrape_max_age_in_s")
        |> Bot.Repo.update_all(set: [value: max_age_in_s])
    end
  end

  defp get_scrape_max_age_setting do
    query = from(u in Bot.Settings, select: u, where: u.key == "rss_scrape_max_age_in_s")

    results = Bot.Repo.all(query)

    case length(results) > 0 do
      true ->
        Enum.at(results, 0).value

      _ ->
        nil
    end
  end

  def get_is_dry_run() do
    setting = get_is_dry_run_setting()

    case setting do
      "true" -> true
      "false" -> false
      _ -> true
    end
  end

  def set_is_dry_run(is_dry_run) do
    case get_is_dry_run_setting() do
      nil ->
        entry = %Bot.Settings{
          key: "rss_is_dry_run",
          value: is_dry_run
        }

        Bot.Repo.insert(entry)

      _ ->
        from(p in Bot.Settings, where: p.key == "rss_is_dry_run")
        |> Bot.Repo.update_all(set: [value: is_dry_run])
    end
  end

  defp get_is_dry_run_setting do
    query = from(u in Bot.Settings, select: u, where: u.key == "rss_is_dry_run")

    results = Bot.Repo.all(query)

    case length(results) > 0 do
      true ->
        Enum.at(results, 0).value

      _ ->
        nil
    end
  end
end

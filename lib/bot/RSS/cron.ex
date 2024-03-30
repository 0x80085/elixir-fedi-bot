defmodule Bot.RSS.Cron do
  use GenServer
  use Ecto.Schema
  import Ecto.Query
  require Logger
  alias Bot.RSS.CronState
  alias BotWeb.Api.RssSettings
  alias Bot.RSS.RssFetcher
  alias Bot.Mastodon

  def start_link(_opts) do
    Logger.info("Started CRON GenServer")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, _state) do
    # Do the work you desire here
    has_credentials = Enum.count(Bot.Mastodon.Auth.PersistCredentials.get_all()) > 0

    case has_credentials do
      true ->
        Logger.info("Credentials found, starting RSS scraping ...")
        fetch_and_post_rss()

      _ ->
        Logger.warn("No credentials found, scraping will not be started")
    end

    # Reschedule once more
    schedule_work()

    CronState.update_state()

    {:noreply, %{}}
  end

  @impl true
  def handle_call(:start_manually, _from, _state) do
    has_credentials = Enum.count(Bot.Mastodon.Auth.PersistCredentials.get_all()) > 0

    case has_credentials do
      true ->
        Logger.info("Credentials found, starting RSS scraping ...")
        Bot.Events.add_event(Bot.Events.new_event("Starting on-demand RSS fetch job...", "Info"))
        fetch_and_post_rss()

      _ ->
        Logger.warn("No credentials found, scraping will not be started")
    end

    CronState.update_state()

    {:reply, :ok, %{}}
  end

  def start_manually() do
    GenServer.call(__MODULE__, :start_manually)
  end

  defp get_enabled_urls do
    query =
      from(u in Bot.RssRepo,
        where: u.is_enabled == true,
        select: u
      )

    Bot.Repo.all(query)
  end

  defp schedule_work() do
    one_minute = 60000
    default_interval = one_minute * 2

    query = from(u in Bot.Settings, select: u, where: u.key == "rss_scrape_interval_in_ms")

    results = Bot.Repo.all(query)

    interval =
      case length(results) > 0 do
        true ->
          Enum.at(results, 0).value
          |> String.to_integer()

        _ ->
          default_interval
      end

    Logger.info("Queued job to run after #{interval}ms ...")

    Process.send_after(self(), :work, interval)
  end

  defp fetch_and_post_rss() do
    current_url_index = CronState.get_current_index()
    Logger.info("Index = #{current_url_index + 1}")
    persisted_urls = get_enabled_urls()
    Logger.info("Size = #{length(persisted_urls)}")

    current_rss_target = Enum.at(persisted_urls, current_url_index)

    current_rss_hashtags = current_rss_target.hashtags
    current_rss_url = current_rss_target.url

    Bot.Events.add_event(Bot.Events.new_event("Starting RSS scraper for #{current_rss_url}", "Info"))
    Logger.info("current_rss_url = #{current_rss_url}")

    case RssFetcher.get_entries(current_rss_url) do
      {:ok, results} ->
        newest_entries = RssFetcher.filter_by_newest(results)
        Logger.info("Got #{length(newest_entries)} results")

        max_post_burst_amount = RssSettings.get_max_post_burst_amount()
        Logger.info("Taking first #{max_post_burst_amount} results")

        Enum.take(newest_entries, max_post_burst_amount)
        |> post_to_fedi_with_delay(current_rss_hashtags)

        Bot.Events.add_event(
          Bot.Events.new_event("OK - RSS fetch completed for #{current_rss_url}", "Info")
        )

      {:error, reason} ->
        Logger.error("RSS fetch failed")
        Logger.error(reason)
        msg = "Warning RSS fetch failed for #{current_rss_url} \r\nReason:\n\r#{reason}"

        Bot.Events.add_event(Bot.Events.new_event(msg, "Warning"))
    end
  end

  defp post_to_fedi_with_delay(entries, hashtags) do
    Enum.each(entries, fn it ->
      random_time_in_ms = Enum.random(1000..5000)

      Logger.info("Posting new entry with a delay of #{random_time_in_ms}ms")
      :timer.sleep(random_time_in_ms)

      credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
      token = credentials.user_token

      Mastodon.Actions.PostStatus.post(
        %{text: it.title, media: it.media, id: it.id, hashtags: hashtags},
        token
      )
    end)
  end
end

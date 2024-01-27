defmodule Bot.RSS.Cron do
  use GenServer
  use Ecto.Schema
  import Ecto.Query
  require Logger
  alias BotWeb.Api.RssSettings
  alias Bot.RSS.RssFetcher
  alias Bot.Mastodon

  @state %{
    url_index: 0
  }

  def start_link(_opts) do
    Logger.info("Started CRON GenServer")
    GenServer.start_link(__MODULE__, @state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the work you desire here
    has_credentials = Bot.Mastodon.Auth.PersistCredentials.has_stored_credentials()

    case has_credentials do
      true ->
        Logger.info("Credentials found, starting RSS scraping ...")
        fetch_and_post_rss(state)

      _ ->
        Logger.warn("No credentials found, scraping will not be started")
    end

    # Reschedule once more
    schedule_work()

    new_state_incremented_index = update_state(state)

    {:noreply, new_state_incremented_index}
  end

  @impl true
  def handle_call(:start_manually, _from, state) do
    has_credentials = Bot.Mastodon.Auth.PersistCredentials.has_stored_credentials()

    case has_credentials do
      true ->
        Logger.info("Credentials found, starting RSS scraping ...")

        fetch_and_post_rss(%{
          url_index: state.url_index
        })

      _ ->
        Logger.warn("No credentials found, scraping will not be started")
    end

    new_state_incremented_index = update_state(state)

    {:reply, :ok, new_state_incremented_index}
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

  defp update_state(state) do
    max_index = length(get_enabled_urls()) - 1

    incremented_url_index =
      case state.url_index == max_index do
        true ->
          0

        _ ->
          state.url_index + 1
      end

    %{
      url_index: incremented_url_index
    }
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

  defp fetch_and_post_rss(state) do
    Bot.Events.add_event(Bot.Events.new_event("Starting RSS scraper", "Info"))
    Logger.info("Index = #{state.url_index + 1}")
    persisted_urls = get_enabled_urls()
    Logger.info("Size = #{length(persisted_urls)}")

    current_rss_target = Enum.at(persisted_urls, state.url_index);

    current_rss_hashtags = current_rss_target.hashtags
    current_rss_url = current_rss_target.url

    Logger.info("current_rss_url = #{current_rss_url}")

    case RssFetcher.get_entries(current_rss_url) do
      {:ok, results} ->
        newest_entries = RssFetcher.filter_by_newest(results)
        Logger.info("Got #{length(newest_entries)} results")
        IO.inspect(newest_entries)

        max_post_burst_amount = RssSettings.get_max_post_burst_amount()
        Logger.info("Taking first #{max_post_burst_amount} results")

        Enum.take(newest_entries, max_post_burst_amount)
        |> post_to_fedi_with_delay(current_rss_hashtags)

        Bot.Events.add_event(Bot.Events.new_event("OK - CRON RSS Job completed for #{current_rss_url}", "Info"))

      {:error, reason} ->
        Logger.error("CRON RSS failed")
        Logger.error(reason)
        msg = "CRON RSS failed for #{current_rss_url} \r\nReason:\n\r#{reason}"

        Bot.Events.add_event(Bot.Events.new_event(msg, "Warning"))
    end
  end

  defp post_to_fedi_with_delay(entries, hashtags) do
    Enum.each(entries, fn it ->
      random_time_in_ms = Enum.random(1000..5000)

      Logger.info("Posting new entry with a delay of #{random_time_in_ms}ms")
      :timer.sleep(random_time_in_ms)

      token = Mastodon.Auth.UserCredentials.get_token()

      Mastodon.Actions.PostStatus.post(
        %{text: it.title, media: it.media, id: it.id, hashtags: hashtags},
        token
      )
    end)
  end
end

defmodule Bot.RSS.Cron do
  use GenServer
  use Ecto.Schema
  import Ecto.Query
  require Logger
  alias BotWeb.Api.RssSettings
  alias Bot.RSS.RssFetcher
  alias Bot.Mastodon

  @state %{
    url_index: 0,
    max_post_burst: 3
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

        is_dry_run = RssSettings.get_is_dry_run()

        fetch_and_post_rss(%{
          is_dry_run: is_dry_run,
          url_index: state.url_index,
          max_post_burst: state.max_post_burst
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
      url_index: incremented_url_index,
      max_post_burst: state.max_post_burst
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
    Logger.info("Index = #{state.url_index}")
    persisted_urls = get_enabled_urls()
    Logger.info("Size = #{length(persisted_urls)}")

    current_rss_url = Enum.at(persisted_urls, state.url_index).url

    Logger.info("current_rss_url = #{current_rss_url}")

    case RssFetcher.get_entries(current_rss_url) do
      {:ok, results} ->
        newest_entries = RssFetcher.filter_by_newest(results)
        Logger.info("Got #{length(newest_entries)} results")
        IO.inspect(newest_entries)

        Logger.info("Taking first #{state.max_post_burst} results")

        is_dry_run = RssSettings.get_is_dry_run()

        Enum.take(newest_entries, state.max_post_burst)
        |> post_to_fedi(is_dry_run)

      {:error, reason} ->
        Logger.error("CRON RSS failed")
        Logger.error(reason)
    end
  end

  defp post_to_fedi(entries, is_dry_run) do
    Enum.each(entries, fn it ->
      # TODO
      random_time_in_ms = Enum.random(1000..5000)

      Logger.info("Posting new entry in #{random_time_in_ms}ms")
      :timer.sleep(random_time_in_ms)

      token = Mastodon.Auth.UserCredentials.get_token()

      Mastodon.Actions.PostStatus.post(
        %{text: it.title, media: it.media, id: it.id},
        token,
        is_dry_run
      )
    end)
  end
end

defmodule Bot.RSS.Cron do
  use GenServer

  alias Bot.RSS.RssUrlsStore
  alias Bot.RSS.RssFetcher
  alias Bot.Mastodon

  @meta_info %{
    is_dry_run: true,
    url_index: 0
  }

  def start_link(_opts) do
    IO.puts("Started CRON GenServer")
    GenServer.start_link(__MODULE__, @meta_info)
  end

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    has_credentials = Bot.Mastodon.Auth.PersistCredentials.has_stored_credentials()

    case has_credentials do
      true ->
        IO.puts("Credentials found, starting RSS scraping ...")
        fetch_and_post_rss(state)

      _ ->
        IO.puts("No credentials found, scraping will not be started")
    end

    # Reschedule once more
    schedule_work()

    new_state_incremented_index = update_state(state)

    {:noreply, new_state_incremented_index}
  end

  defp update_state(state) do
    max_index = length(RssUrlsStore.get_urls()) - 1

    incremented_url_index =
      case state.url_index == max_index do
        true ->
          0

        _ ->
          state.url_index + 1
      end

    %{
      is_dry_run: state.is_dry_run,
      url_index: incremented_url_index
    }
  end

  defp schedule_work() do
    two_hours = 2 * 60 * 60 * 1000

    # (debug) Every minute
    # one_minute = 60000
    twenty_secs_in_ms = 1000 * 20
    IO.puts("Queued job to run after #{twenty_secs_in_ms}ms ...")
    Process.send_after(self(), :work, twenty_secs_in_ms)
  end

  defp fetch_and_post_rss(state) do
    IO.puts("Index = #{state.url_index}")
    IO.puts("Size = #{length(RssUrlsStore.get_urls())}")

    current_rss_url = Enum.at(RssUrlsStore.get_urls(), state.url_index)

    IO.puts("current_rss_url = #{current_rss_url}")

    case RssFetcher.get_entries(current_rss_url) do
      {:ok, results} ->
        IO.puts("Got #{length(results)} results")
        IO.inspect(results)
        post_to_fedi(results, state.is_dry_run)

      {:error, reason} ->
        IO.puts("CRON RSS failed")
        IO.puts(reason)
    end
  end

  defp post_to_fedi(entries, is_dry_run) do
    Enum.each(entries, fn it ->
      # TODO
      random_time_in_ms = Enum.random(1000..5000)

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

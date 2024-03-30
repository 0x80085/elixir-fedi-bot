defmodule Bot.RSS.CronState do
  require Logger
  use Agent
  use Ecto.Schema

  import Ecto.Query

  @default_state %{
    url_index: 0
  }

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        @default_state
      end,
      name: __MODULE__
    )
  end

  def get_current_index() do
    Agent.get(__MODULE__, fn state ->
      state.url_index
    end)
  end

  def get_next_up_rss_url() do
    Agent.get(__MODULE__, fn state ->
      persisted_urls = get_enabled_urls()

      cond do
        length(persisted_urls) > 0 ->
          Enum.at(persisted_urls, state.url_index).url

        true ->
          "No URLs found"
      end
    end)
  end

  def update_state() do
    Agent.update(__MODULE__, fn state ->
      urls = get_enabled_urls()

      max_index = length(urls) - 1

      incremented_url_index =
        case state.url_index >= max_index do
          true ->
            max_index

          _ ->
            state.url_index + 1
        end

      Logger.info("Updated cron state index: #{incremented_url_index}")

      if length(urls) > 0 do
        next_up = Enum.at(urls, incremented_url_index)

        Bot.Events.add_event(
          Bot.Events.new_event("Updated next up RSS target: #{next_up.url}", "Info")
        )
      end

      %{
        url_index: incremented_url_index
      }
    end)
  end

  def cap_url_index_on_enabled_urls_size() do
    Agent.update(__MODULE__, fn state ->
      urls = get_enabled_urls()
      max_index = length(urls) - 1

      capped_url_index =
        case state.url_index >= max_index do
          true ->
            Logger.info("Capped cron state index: #{max_index}")

            if length(urls) > 0 do
              next_up = Enum.at(urls, max_index)

              Bot.Events.add_event(
                Bot.Events.new_event("Updated next up RSS target: #{next_up.url}", "Info")
              )
            end

            max_index

          _ ->
            state.url_index
        end

      %{
        url_index: capped_url_index
      }
    end)
  end

  defp get_enabled_urls do
    query =
      from(u in Bot.RssRepo,
        where: u.is_enabled == true,
        select: u
      )

    Bot.Repo.all(query)
  end
end

defmodule Bot.RSS.CronState do
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
      Enum.at(persisted_urls, state.url_index).url
    end)
  end

  def update_state() do
    Agent.update(__MODULE__, fn state ->
      max_index = length(get_enabled_urls()) - 1

      incremented_url_index =
        case state.url_index == max_index do
          true ->
            0

          _ ->
            state.url_index + 1
        end

      IO.inspect("updated cron state index:")
      IO.inspect(incremented_url_index)

      %{
        url_index: incremented_url_index
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

defmodule Bot.RSS.RssUrlsStore do
  use Agent

  @rss_urls [
    # test bad fetch
    # "https://nitter.snopyta.org/_ENTER_NAME_/rss",

    # test twatter
    # "https://nitter.snopyta.org/censoredgaming_/rss",

    # Feed of anime episodes that have aired in the last 24 hours
    "https://www.livechart.me/feeds/episodes",

    # youtube channels feeds
    # CensoredGaming
    "https://www.youtube.com/feeds/videos.xml?channel_id=UCFItIX8SIs4zqhJCHpbeV1A",
    # TODO
    # "https://www.youtube.com/feeds/videos.xml?channel_id=",

    # LiveChart.me aka anime news stuff
    # Feed of the latest anime headlines curated by the LiveChart.me team
    "https://www.livechart.me/feeds/headlines",

    # Twitter rss
    # censoredgaming
    "https://nitter.snopyta.org/censoredgaming_/rss"
  ]

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        %{urls: @rss_urls}
      end,
      name: __MODULE__
    )
  end

  def get_urls() do
    Agent.get(__MODULE__, fn state ->
      state.urls
    end)
  end

  def add(url) do
    Agent.update(__MODULE__, fn state ->
      IO.inspect(url)
      IO.inspect(state)
      case Enum.any?(state.urls, fn it -> it == url end) do
        false ->
          new_ls = Enum.concat(state.urls, [url])
          IO.inspect(new_ls)
          %{
            urls: new_ls
          }

        _ ->
          state
      end
    end)
  end
end

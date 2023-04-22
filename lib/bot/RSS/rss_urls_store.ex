defmodule Bot.RSS.RssUrlsStore do
  # use Agent # ?  not sure if needed

  @rss_urls [
    # test bad fetch
    # "https://nitter.snopyta.org/_ENTER_NAME_/rss",

    # test twatter
    # "https://nitter.snopyta.org/censoredgaming_/rss",


    # youtube channels feeds
    # CensoredGaming
    "https://www.youtube.com/feeds/videos.xml?channel_id=UCFItIX8SIs4zqhJCHpbeV1A",
    # TODO
    # "https://www.youtube.com/feeds/videos.xml?channel_id=",

    # LiveChart.me aka anime news stuff
    # Feed of the latest anime headlines curated by the LiveChart.me team
    "https://www.livechart.me/feeds/headlines",
    # Feed of anime episodes that have aired in the last 24 hours
    "https://www.livechart.me/feeds/episodes",

    # Twitter rss
    # censoredgaming
    "https://nitter.snopyta.org/censoredgaming_/rss",
  ]

  def get_urls do
    @rss_urls
  end
end

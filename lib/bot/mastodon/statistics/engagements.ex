defmodule Bot.Mastodon.Statistics.Engagements do
  def total_engagements_last_24h() do
    {statuses, :done} = Bot.Mastodon.Statistics.Statuses24h.get()

    engagements_today =
      Enum.reduce(statuses, %{favs: 0, boosts: 0, replies: 0, mentions: 0}, fn toot, counts ->
        %{
          favs: counts.favs + toot["favourites_count"],
          boosts: counts.boosts + toot["reblogs_count"],
          replies: counts.replies + toot["replies_count"],
          mentions: counts.mentions
        }
      end)

    total_engagements_today =
      engagements_today.favs + engagements_today.boosts + engagements_today.replies +
        engagements_today.mentions

    total_engagements_today
  end
end

defmodule Bot.Mastodon.Statistics.Frequency do
  def average_of_toots_per_hour_last_24h() do
    case Enum.count(Bot.Mastodon.Auth.PersistCredentials.get_all()) > 0 do
      true ->
        {statuses, :done} = Bot.Mastodon.Statistics.Statuses24h.get()

        now = Timex.now()

        count =
          Enum.count(statuses, fn toot ->
            toot_timestamp = Timex.parse!(toot["created_at"], "{ISO:Extended}")
            day_ago_in_s = 86400
            Timex.diff(now, toot_timestamp, :seconds) < day_ago_in_s
          end)

        # Calculate average toots per hour
        count / 24.0

      _ ->
        "Link Mastodon account to use this feature."
    end
  end
end

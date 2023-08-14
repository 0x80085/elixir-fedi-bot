defmodule Bot.Mastodon.Statistics.Engagements do
  def total_engagements_last_24h() do
    statuses = get_statuses()
    now = Timex.now()

    engagements_today =
      Enum.reduce(statuses, %{favs: 0, boosts: 0, replies: 0}, fn toot, counts ->
        created_at = Timex.parse!(toot["created_at"], "{ISO:Extended}")
        is_24h_ago = Timex.diff(now, created_at, :seconds) < 86400

        if is_24h_ago do
          %{
            favs: counts.favs + toot["favourites_count"],
            boosts: counts.boosts + toot["reblogs_count"],
            replies: counts.replies + toot["replies_count"]
          }
        else
          counts
        end
      end)

    total_engagements_today =
      engagements_today.favs + engagements_today.boosts + engagements_today.replies

    IO.puts("Total engagements today: #{total_engagements_today}")

    total_engagements_today
  end

  defp get_statuses() do
    token = Bot.Mastodon.Auth.UserCredentials.get_token()
    account_id = Bot.Mastodon.Auth.UserCredentials.get_account_id()
    fedi_url = Bot.Mastodon.Auth.ApplicationCredentials.get_fedi_url()

    headers = [{"Authorization", "Bearer #{token}"}]

    case HTTPoison.get("#{fedi_url}/api/v1/accounts/#{account_id}/statuses", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)

      {:ok, %HTTPoison.Response{status_code: code}} ->
        IO.puts("Request failed with status code #{code}")
        []

      {:error, reason} ->
        IO.puts("Request error: #{reason}")
        []
    end
  end
end

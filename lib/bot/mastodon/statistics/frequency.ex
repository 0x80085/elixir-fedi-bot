defmodule Bot.Mastodon.Statistics.Frequency do
  def average_of_toots_per_hour_last_24h() do
    case Enum.count(Bot.Mastodon.Auth.PersistCredentials.get_all()) > 0 do
      true ->
        toots = get_toots()
        now = Timex.now()

        count =
          Enum.count(toots, fn toot ->
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

  defp get_toots() do
    credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
    token = credentials.user_token
    account_id = credentials.account_id
    fedi_url = credentials.fedi_url

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

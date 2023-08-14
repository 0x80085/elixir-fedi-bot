defmodule Bot.Mastodon.Statistics.Frequency do
  def calculate_toot_frequency() do
    case Bot.Mastodon.Auth.PersistCredentials.has_stored_credentials() do
      true ->
        toots = get_toots()
        now = Timex.now()

        count =
          Enum.count(toots, fn toot ->
            toot_timestamp = Timex.parse!(toot["created_at"], "{ISO:Extended}")
            # Count toots posted within the last 24 hours
            Timex.diff(now, toot_timestamp, :seconds) < 86400
          end)

        # Calculate average toots per hour
        frequency = count / 24.0
        IO.puts("Average toots per hour: #{frequency}")

        frequency

      _ ->
        "Link Mastodon account to use this feature."
    end
  end

  defp get_toots() do
    token = Bot.Mastodon.Auth.UserCredentials.get_token()
    account_id = Bot.Mastodon.Auth.UserCredentials.get_account_id()
    fedi_url = Bot.Mastodon.Auth.ApplicationCredentials.get_fedi_url()

    headers = [{"Authorization", "Bearer #{token}"}]
    IO.inspect("#{fedi_url}/api/v1/accounts/#{account_id}/statuses")

    case HTTPoison.get("#{fedi_url}/api/v1/accounts/#{account_id}/statuses", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect("body !!!!")
        IO.inspect(body)
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

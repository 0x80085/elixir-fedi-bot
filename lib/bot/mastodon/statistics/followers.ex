defmodule Bot.Mastodon.Statistics.Followers do
  def total_followers() do
    token = Bot.Mastodon.Auth.UserCredentials.get_token()
    account_id = Bot.Mastodon.Auth.UserCredentials.get_account_id()
    fedi_url = Bot.Mastodon.Auth.ApplicationCredentials.get_fedi_url()

    headers = [{"Authorization", "Bearer #{token}"}]

    case HTTPoison.get("#{fedi_url}/api/v1/accounts/#{account_id}", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, account_data} = Jason.decode(body)
        follower_count = account_data["followers_count"]
        IO.puts("Follower Count: #{follower_count}")
        follower_count

      {:ok, %HTTPoison.Response{status_code: code}} ->
        IO.puts("Request failed with status code #{code}")
        "???"

      {:error, reason} ->
        IO.puts("Request error: #{reason}")
        "Error"
    end
  end
end

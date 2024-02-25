defmodule Bot.Mastodon.Statistics.AccountInfo do
  def account_info() do
    credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
    token = credentials.user_token
    account_id = credentials.account_id
    fedi_url = credentials.fedi_url

    headers = [{"Authorization", "Bearer #{token}"}]

    case HTTPoison.get("#{fedi_url}/api/v1/accounts/#{account_id}", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, account_data} = Jason.decode(body)

        username = account_data["username"]
        follower_count = account_data["followers_count"]
        post_count = account_data["statuses_count"]
        avatar_url = account_data["avatar_static"]

        account_age_in_days = get_days_ago(account_data["created_at"])

        %{
          username: username,
          avatar_url: avatar_url,
          account_age_in_days: account_age_in_days,
          total_followers: follower_count,
          post_count: post_count
        }

      {:ok, %HTTPoison.Response{status_code: code}} ->
        IO.puts("Request failed with status code #{code}")

        %{
          username: "error",
          avatar_url: "error",
          account_age: "error",
          total_followers: "error",
          post_count: "error"
        }

      {:error, reason} ->
        IO.puts("Request error: #{reason}")

        %{
          username: "error",
          avatar_url: "error",
          account_age: "error",
          total_followers: "error",
          post_count: "error"
        }
    end
  end

  defp get_days_ago(date) do
    account_age =
      date
      |> Timex.parse!("{ISO:Extended}")

    Timex.diff(Timex.now(), account_age, :days)
  end
end

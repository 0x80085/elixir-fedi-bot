defmodule Bot.Mastodon.UserCredentials do
  def authorize_bot_to_user(client_id, client_secret, token, user_code) do
    url = "https://mas.to/oauth/token"

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"},
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    data = [
      client_id: client_id,
      client_secret: client_secret,
      scope: "read write push",
      grant_type: "authorization_code",
      code: user_code,
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    ]

    reponse = HTTPoison.post(url, {:form, data}, headers)

    case reponse do
      {:ok, result} ->
        decoded = Jason.decode(result.body)

        case decoded do
          {:ok, body} ->
            user_token = "Bearer #{Map.get(body, "access_token")}"
            IO.puts("Got user token !! #{user_token}")

            Bot.Mastodon.VerifyCredentials.verify_token(
              user_token,
              "https://mas.to/api/v1/accounts/verify_credentials"
            )

            {:ok, token: user_token}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end

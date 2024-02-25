defmodule Bot.Mastodon.Auth.UserCredentials do
  require Logger

  def authorize_bot_to_user(client_id, client_secret, token, user_code) do
    credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
    fedi_url = credentials.fedi_url

    url = "#{fedi_url}/oauth/token"

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
            Logger.info("Got user token, verifying it..")

            url = "#{fedi_url}/api/v1/accounts/verify_credentials"

            case Bot.Mastodon.Auth.VerifyCredentialsV2.verify_token(user_token, url) do
              {:ok, account_data} ->
                account_id = Map.get(account_data, "id")

                credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
                fedi_url = credentials.fedi_url

                Bot.Mastodon.Auth.PersistCredentials.complete_bot_registration(%{
                  client_id: client_id,
                  client_secret: client_secret,
                  app_token: token,
                  user_token: user_token,
                  fedi_url: fedi_url,
                  account_id: account_id
                })

                {:ok, user_token}

              {:error, reason} ->
                {:error, reason}
            end

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end

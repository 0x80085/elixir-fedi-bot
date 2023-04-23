defmodule Bot.Mastodon.Auth.UserCredentials do
  use Agent

  @default_state %{
    token: nil
  }

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        creds = Bot.Mastodon.Auth.PersistCredentials.get_from_file()

        case creds do
          nil ->
            IO.puts("No user token found")
            @default_state

          creds ->
            IO.puts("User token found, using from files")
            IO.puts("user_token: #{Map.get(creds, "user_token")}")
            %{
              token: Map.get(creds, "user_token"),
            }
        end
      end,
      name: __MODULE__
    )
  end

  @spec get_token :: String
  def get_token() do
    Agent.get(__MODULE__, fn state ->
      state.token
    end)
  end

  def set_token(token) do
    Agent.update(__MODULE__, fn _state ->
      %{
        token: token
      }
    end)
  end

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

            is_token_valid(user_token)

            Bot.Mastodon.Auth.PersistCredentials.encode_and_persist(%{
              client_id: client_id,
              client_secret: client_secret,
              app_token: token,
              user_token: user_token
            })

            {:ok, user_token}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def is_token_valid(user_token) do
    case Bot.Mastodon.Auth.VerifyCredentials.verify_token(
           user_token,
           "https://mas.to/api/v1/accounts/verify_credentials"
         ) do
      {:ok, _result} ->
        set_token(user_token)
        {:ok, user_token}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

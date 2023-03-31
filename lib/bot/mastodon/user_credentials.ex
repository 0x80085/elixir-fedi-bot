defmodule Bot.Mastodon.UserCredentials do
  # curl -X POST \
  # -F 'client_id=your_client_id_here' \
  # -F 'client_secret=your_client_secret_here' \
  # -F 'redirect_uri=urn:ietf:wg:oauth:2.0:oob' \
  # -F 'grant_type=authorization_code' \
  # -F 'code=user_authzcode_here' \
  # -F 'scope=read write push' \
  # https://mastodon.example/oauth/token

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

    #########

    # options = %{
    #   "client_id" => client_id,
    #   "client_secret" => client_secret,
    #   "redirect_uri" => "urn:ietf:wg:oauth:2.0:oob",
    #   "scope" => "read write push",
    #   "grant_type" => "authorization_code",
    #   "code" => user_code
    # }

    # request_body = URI.encode_query(options)

    # reponse = HTTPoison.post("https://mas.to/oauth/token", request_body, [])

    case reponse do
      {:ok, result} ->
        decoded = Jason.decode(result.body)

        case decoded do
          {:ok, body} ->
            user_token = "Bearer #{Map.get(body, "access_token")}"
            IO.puts("Got user token !! #{user_token}")

            verify_credentials(user_token)

            {:ok, token: user_token}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def verify_credentials(token) do

  #   curl \
	# -H 'Authorization: Bearer our_access_token_here' \
	# https://mastodon.example/api/v1/accounts/verify_credentials

    IO.puts("Verifying token: #{token}")

    headers = [
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    response = HTTPoison.get("https://mas.to/api/v1/accounts/verify_credentials", headers)

    case response do
      {:ok, result} ->
        case result.status_code do
          200 ->
            IO.puts("SUCCESS Token verified !")

          _ ->
            IO.puts("FAILED Token NOT verified... status: #{result.status_code}")

            case Jason.decode(result.body) do
              {:ok, body} ->
                IO.puts(Map.get(body, "error"))

              {:error, reason} ->
                IO.puts("error body not decoded")
                IO.puts(reason)
            end
        end

        {:ok, result}

      {:error, reason} ->
        IO.puts("FAILED Token NOT verified...")
        IO.puts("#{reason}")
        {:error, reason}
    end
  end
end

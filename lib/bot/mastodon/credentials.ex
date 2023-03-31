defmodule Bot.Mastodon.Credentials do
  use Agent

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        case get_client_connect_info() do
          {:ok, info} ->
            create_client(info)

          {:error, reason} ->
            IO.puts("encountered error #{reason}")
        end
      end,
      name: __MODULE__
    )
  end

  @spec get_client() :: OAuth2.Client
  def get_client() do
    Agent.get(__MODULE__, fn state ->
      state.client
    end)
  end

  @spec get_token :: String
  def get_token() do
    Agent.get(__MODULE__, fn state ->
      state.token
    end)
  end

  def get_client_connect_info() do
    IO.puts("getting connect info")

    payload = %{
      "client_name" => "Bot Test Application",
      "redirect_uris" => "urn:ietf:wg:oauth:2.0:oob",
      "scopes" => "read write push",
      "website" => "http://localhost"
    }

    request_body = URI.encode_query(payload)

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    response = HTTPoison.post("https://mas.to/api/v1/apps", request_body, headers)

    case response do
      {:ok, result} ->
        case Jason.decode(result.body) do
          {:ok, decoded} ->
            client_id = Map.get(decoded, "client_id")
            client_secret = Map.get(decoded, "client_secret")

            IO.puts("Successfully fetched connect info")
            IO.puts(client_id)
            IO.puts(client_secret)

            {:ok, %{client_id: client_id, client_secret: client_secret}}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        IO.puts("error fetching connect info")
        IO.puts(reason)
        {:error, reason}
    end
  end

  def create_client(connect_info) do
    IO.puts("Create client and get token")
    IO.puts(connect_info.client_id)
    IO.puts(connect_info.client_secret)
    IO.puts("---")

    client =
      OAuth2.Client.new(
        strategy: OAuth2.Strategy.ClientCredentials,
        client_id: connect_info.client_id,
        client_secret: connect_info.client_secret,
        # todo get from env
        site: "https://mas.to"
      )

    # Request a token from with the newly created client
    # Token will be stored inside the `%OAuth2.Client{}` struct (client.token)
    client = OAuth2.Client.get_token!(client)

    # client.token contains the `%OAuth2.AccessToken{}` struct
    case Jason.decode(client.token.access_token) do
      {:ok, result} ->
        token = Map.get(result, "access_token")
        IO.puts(token)
        IO.puts("^^^^^^ Got oauth TOKEN!")
        verify_credentials("Bearer #{token}")
        %{client: client, token: "Bearer #{token}"}

      {:error, result} ->
        IO.puts("error fetching token: #{result}")
    end
  end

  def verify_credentials(token) do
    IO.puts("Verifying token: #{token}")

    headers = [
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    response = HTTPoison.get("https://mas.to/api/v1/apps/verify_credentials", headers)

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

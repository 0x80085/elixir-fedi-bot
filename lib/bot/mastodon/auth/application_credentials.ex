defmodule Bot.Mastodon.Auth.ApplicationCredentials do
  use Agent
  require Logger

  @default_state %{
    client_id: nil,
    client_secret: nil,
    token: nil,
    fedi_url: nil,
    client: nil
  }

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        creds = Enum.at(Bot.Mastodon.Auth.PersistCredentials.get_all(), 0)

        case creds do
          nil ->
            Logger.warn("Fedi creds not found")
            @default_state

          creds ->
            Logger.info("Fedi creds found, using from DB")
            Logger.info("fedi instance url: #{creds.fedi_url}")
            Logger.info("app token: #{creds.app_token}")

            %{
              client_id: creds.client_id,
              client_secret: creds.client_secret,
              token: creds.app_token,
              fedi_url: creds.fedi_url,
              client: nil
            }
        end
      end,
      name: __MODULE__
    )
  end

  def setup_credentials(fedi_url) do
    case get_client_connect_info(fedi_url) do
      {:ok, info} ->
        client_info = create_client(info, fedi_url)
        IO.inspect("should save cres here ####")
        IO.inspect(info)
        IO.inspect(client_info.client_id)
        IO.inspect(client_info.token)

        Bot.Mastodon.Auth.PersistCredentials.insert(%{
          client_id: client_info.client_id,
          client_secret: info.client_secret,
          app_token: client_info.token,
          user_token: "",
          fedi_url: fedi_url,
          account_id: ""
        })

        {:ok,
         %{
           client_id: client_info.client_id,
           client_secret: info.client_secret,
           token: client_info.token,
           auth_url:
             "#{fedi_url}/oauth/authorize?client_id=#{client_info.client_id}&scope=read+write+push&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code"
         }}

      {:error, reason} ->
        Logger.error("encountered error during setup credentials: #{reason}")
        {:error, reason}
    end
  end

  def get_client_connect_info(fedi_url) do
    Logger.info("getting connect info")

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

    response = HTTPoison.post("#{fedi_url}/api/v1/apps", request_body, headers)

    case response do
      {:ok, result} ->
        case Jason.decode(result.body) do
          {:ok, decoded} ->
            client_id = Map.get(decoded, "client_id")
            client_secret = Map.get(decoded, "client_secret")

            Logger.info("Successfully fetched connect info")
            Logger.info(client_id)
            Logger.info(client_secret)

            {:ok, %{client_id: client_id, client_secret: client_secret}}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        Logger.warn("error fetching connect info")
        Logger.warn(reason)
        {:error, reason}
    end
  end

  def create_client(connect_info, fedi_url) do
    Logger.info("Create client and get token")
    Logger.info(connect_info.client_id)
    Logger.info(connect_info.client_secret)
    Logger.info("---")

    client =
      OAuth2.Client.new(
        strategy: OAuth2.Strategy.ClientCredentials,
        client_id: connect_info.client_id,
        client_secret: connect_info.client_secret,
        site: "#{fedi_url}"
      )

    client = OAuth2.Client.get_token!(client)

    case Jason.decode(client.token.access_token) do
      {:ok, result} ->
        token = "Bearer #{Map.get(result, "access_token")}"
        Logger.info("Got OAuth client token! Verifying...")

        Bot.Mastodon.Auth.VerifyCredentialsV2.verify_token(
          token,
          "#{fedi_url}/api/v1/apps/verify_credentials"
        )

        %{
          token: token,
          client_id: connect_info.client_id,
          client_secret: connect_info.client_secret
        }

      {:error, result} ->
        Logger.error("error fetching token: #{result}")
    end
  end
end

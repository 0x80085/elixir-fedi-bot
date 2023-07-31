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
        creds = Bot.Mastodon.Auth.PersistCredentials.get_from_file()

        case creds do
          nil ->
            Logger.warn("Fedi creds not found")
            @default_state

          creds ->
            Logger.debug("Fedi creds found, using from files")
            Logger.debug("fedi instance url: #{Map.get(creds, "fedi_url")}")
            Logger.debug("app token: #{Map.get(creds, "app_token")}")

            %{
              client_id: Map.get(creds, "client_id"),
              client_secret: Map.get(creds, "client_secret"),
              token: Map.get(creds, "app_token"),
              fedi_url: Map.get(creds, "fedi_url"),
              client: nil
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

  @spec get_client_id :: String
  def get_client_id() do
    Agent.get(__MODULE__, fn state ->
      state.client_id
    end)
  end

  @spec get_client_secret :: String
  def get_client_secret() do
    Agent.get(__MODULE__, fn state ->
      state.client_secret
    end)
  end

  @spec get_fedi_url :: String
  def get_fedi_url() do
    Agent.get(__MODULE__, fn state ->
      state.fedi_url
    end)
  end

  def set_token(token) do
    Agent.update(__MODULE__, fn state ->
      %{
        token: token,
        client_id: state.client_id,
        client_secret: state.client_secret,
        fedi_url: state.fedi_url,
        client: state.client
      }
    end)
  end

  def set_client_id(client_id) do
    Agent.update(__MODULE__, fn state ->
      %{
        client_id: client_id,
        token: state.token,
        client_secret: state.client_secret,
        fedi_url: state.fedi_url,
        client: state.client
      }
    end)
  end

  def set_client_secret(client_secret) do
    Agent.update(__MODULE__, fn state ->
      %{
        client_secret: client_secret,
        client_id: state.client_id,
        token: state.token,
        fedi_url: state.fedi_url,
        client: state.client
      }
    end)
  end

  def set_fedi_url(fedi_url) do
    Agent.update(__MODULE__, fn state ->
      %{
        client_secret: state.client_secret,
        client_id: state.client_id,
        token: state.token,
        fedi_url: fedi_url,
        client: state.client
      }
    end)
  end

  def setup_credentials(fedi_url) do
    case get_client_connect_info(fedi_url) do
      {:ok, info} ->
        client_info = create_client(info, fedi_url)

        set_client_id(client_info.client_id)
        set_client_secret(info.client_secret)
        set_token(client_info.token)
        set_fedi_url(fedi_url)

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
    Logger.debug("getting connect info")

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

            Logger.debug("Successfully fetched connect info")
            Logger.debug(client_id)
            Logger.debug(client_secret)

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
    Logger.debug("Create client and get token")
    Logger.debug(connect_info.client_id)
    Logger.debug(connect_info.client_secret)
    Logger.debug("---")

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
        Logger.debug("Got oauth TOKEN!")

        Bot.Mastodon.Auth.VerifyCredentials.verify_token(
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

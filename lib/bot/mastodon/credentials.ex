defmodule Bot.Mastodon.Credentials do
  use Agent

  @default_state %{
    client: nil,
    token: nil
  }

  def start_link(_opts) do
    Agent.start_link(fn ->
      create_client()
    end)
  end

  @spec get_client() :: OAuth2.Client
  def get_client() do
    Agent.get(__MODULE__, fn state ->
      state.client
    end)
  end

  # @spec create_client :: %{client: OAuth2.Client.t(), token: String}
  def create_client() do
    client =
      OAuth2.Client.new(
        strategy: OAuth2.Strategy.ClientCredentials,
        client_id: "jdGqZbKZYVa5EwJLAwOQhYlKyiVaXK4oOxnGCnSHbQw",
        client_secret: "QiQa54-hAuw5SePX35yi7ci9qOA97S_8AfHTGRqQKq0",
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
        %{client: client, token: "Bearer #{token}"}

      {:error, result} ->
        IO.puts("error fetching token: #{result}")
    end

    IO.puts("^^^^^^ OTOKEN")
  end
end

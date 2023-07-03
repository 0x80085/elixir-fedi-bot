defmodule Bot.Chatgpt.CredentialStore do
  use Agent

  @default_state %{
    secret_key: nil
  }

  def start_link(_opts) do
    Agent.start_link(
      fn ->
        creds = Bot.Chatgpt.CredentialsWrite.get_from_file()

        case creds do
          nil ->
            IO.puts("ChatGPT creds not found")
            @default_state

          creds ->
            IO.puts("Chatgpt Creds found, using from files")
            IO.puts("Chatgpt api token: #{Map.get(creds, "secret_key")}")

            %{
              secret_key: Map.get(creds, "secret_key")
            }
        end
      end,
      name: __MODULE__
    )
  end

  @spec get_secret_key :: String
  def get_secret_key() do
    Agent.get(__MODULE__, fn state ->
      state.secret_key
    end)
  end

  def set_secret_key(token) do
    Agent.update(__MODULE__, fn _ ->
      %{
        secret_key: token
      }
    end)
  end
end

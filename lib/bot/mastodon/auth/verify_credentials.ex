defmodule Bot.Mastodon.Auth.VerifyCredentials do
  require Logger

  def verify_token(token, url) do
    Logger.debug("Verifying token: #{token}")
    Logger.debug("at URL: #{url}")

    headers = [
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    response = HTTPoison.get(url, headers)

    case response do
      {:ok, result} ->
        case result.status_code do
          200 ->
            Logger.debug("SUCCESS Token verified !")

            case Jason.decode(result.body) do
              {:ok, body} ->
                Logger.debug(Map.get(body, "error"))
                {:ok, result}

              {:error, reason} ->
                Logger.debug("error body not decoded")
                Logger.debug(reason)
                {:error, reason}
            end

          _ ->
            Logger.error("FAILED Token NOT verified... status: #{result.status_code}")
            {:error, result.status_code}
        end

      {:error, reason} ->
        Logger.error("FAILED Token NOT verified...")
        Logger.error("#{reason}")
        {:error, reason}
    end
  end
end

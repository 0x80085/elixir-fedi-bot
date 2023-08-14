defmodule Bot.Mastodon.Auth.VerifyCredentials do
  require Logger

  def verify_token(token, url) do
    Logger.info("Verifying token: #{token}")
    Logger.info("at URL: #{url}")

    headers = [
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    response = HTTPoison.get(url, headers)

    case response do
      {:ok, result} ->
        case result.status_code do
          200 ->
            Logger.info("SUCCESS Token verified !")

            case Jason.decode(result.body) do
              {:ok, body} ->
                Logger.info(Map.get(body, "error", "verify_token succeeded"))
                {:ok, result}

              {:error, reason} ->
                Logger.info("error body not decoded")
                Logger.info(reason)
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

defmodule Bot.Mastodon.Auth.VerifyCredentialsV2 do
  require Logger

  def verify_token(user_token, url) do

    Logger.info("Verifying token: #{user_token}")
    Logger.info("at URL: #{url}")

    headers = [
      {"Accept", "application/json"},
      {"Authorization", user_token}
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
                {:ok, body}

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

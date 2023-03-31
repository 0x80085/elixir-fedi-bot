defmodule Bot.Mastodon.Auth.VerifyCredentials do
  def verify_token(token, url) do
    IO.puts("Verifying token: #{token}")
    IO.puts("at URL: #{url}")

    headers = [
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    response = HTTPoison.get(url, headers)

    case response do
      {:ok, result} ->
        case result.status_code do
          200 ->
            IO.puts("SUCCESS Token verified !")

            case Jason.decode(result.body) do
              {:ok, body} ->
                IO.puts(Map.get(body, "error"))
                {:ok, result}

              {:error, reason} ->
                IO.puts("error body not decoded")
                IO.puts(reason)
                {:error, reason}
            end

          _ ->
            IO.puts("FAILED Token NOT verified... status: #{result.status_code}")
            {:error, result.status_code}
        end

      {:error, reason} ->
        IO.puts("FAILED Token NOT verified...")
        IO.puts("#{reason}")
        {:error, reason}
    end
  end
end

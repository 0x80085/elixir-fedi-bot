defmodule Bot.Chatgpt.ChatActions do
  def chat_with_gpt(text) do
    api_key = Bot.Chatgpt.CredentialStore.get_secret_key()

    IO.puts("Asking GPT using api_key vv")
    IO.inspect(api_key)

    # 1 min timeout bc chatgpt takes a while to complete
    options = [recv_timeout: 60000]

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    body =
      Jason.encode!(%{
        model: "gpt-3.5-turbo",
        messages: [%{role: "user", content: "#{text}"}]
      })

    response =
      HTTPoison.post("https://api.openai.com/v1/chat/completions", body, headers, options)

    case response do
      {:ok, result} ->
        case Jason.decode(result.body) do
          {:ok, decoded} ->
            IO.puts("Successfully fetched answer from GPT")
            IO.inspect(decoded)

            answer =
              Map.get(decoded, "choices")
              |> Enum.at(0)
              |> Map.get("message")
              |> Map.get("content")

            IO.puts(answer)

            {:ok, %{answer: answer}}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        IO.puts("error chatting with GPT")
        IO.puts(reason)
        {:error, reason}
    end
  end
end

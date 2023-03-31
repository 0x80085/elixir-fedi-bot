defmodule Bot.Mastodon.Actions.PostStatus do
  def post(text, token) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"},
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    request_body =
      URI.encode_query(%{
        "status" => text
        # "media_ids" => [] # How to array queryparams in elixir?
      })

    reponse = HTTPoison.post("https://mas.to/api/v1/statuses", request_body, headers)

    case reponse do
      {:ok, result} ->
        decoded = Jason.decode(result.body)

        case decoded do
          {:ok, _body} ->
            # todo verify 200 ok
            {:ok, "status posted"}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end

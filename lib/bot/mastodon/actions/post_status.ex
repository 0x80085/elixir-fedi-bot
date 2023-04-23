defmodule Bot.Mastodon.Actions.PostStatus do
  def post(text, token, is_dry_run) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"},
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    request_body =
      Plug.Conn.Query.encode(
        %{
          "status" => text,
          "media_ids" => []
        }
      )

    if is_dry_run do

      IO.inspect("DRY RUN: Was going to post:")
      IO.inspect(request_body)
      IO.inspect(headers)
      IO.puts("###")

      {:ok, "status printed"}
    else
      IO.inspect("Posting to fedi...")
      IO.inspect("Status: #{text}")
      IO.inspect(request_body)
      reponse = HTTPoison.post("https://mas.to/api/v1/statuses", request_body, headers)

      case reponse do
        {:ok, result} ->
          decoded = Jason.decode(result.body)

          case decoded do
            {:ok, body} ->
              # todo verify 200 ok
              IO.inspect("Status posted!")
              IO.inspect(body)
              {:ok, "status posted"}

            {:error, reason} ->
              {:error, reason}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end

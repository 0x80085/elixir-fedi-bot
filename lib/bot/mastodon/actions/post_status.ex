defmodule Bot.Mastodon.Actions.PostStatus do
  def post(data, token, is_dry_run) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"},
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    request_body =
      Plug.Conn.Query.encode(%{
        "status" => data.text,
        "media_ids" => data.media || []
      })

    if is_dry_run do
      IO.inspect("DRY RUN: Was going to post:")
      IO.inspect(request_body)
      IO.inspect(headers)
      IO.puts("###")

      {:ok, "status printed"}
    else
      was_already_posted = Bot.RSS.FoundUrlArchive.exists(data.id)

      if was_already_posted do
        IO.inspect("Already posted, ignoring: #{data.id}")
      else
        IO.inspect("Posting to fedi...")
        IO.inspect("id: #{data.id}")
        IO.inspect(request_body)

        reponse = HTTPoison.post("https://mas.to/api/v1/statuses", request_body, headers)

        case reponse do
          {:ok, result} ->
            IO.inspect(result)
            IO.inspect(result.status_code)
            decoded = Jason.decode(result.body)

            case result.status_code do
              200 ->
                IO.inspect("Status posted!")

                IO.inspect("Archiving ID")
                Bot.RSS.FoundUrlArchive.add_entry_id(data.id)

                case decoded do
                  {:ok, body} ->
                    # todo verify 200 ok
                    IO.inspect(body)
                    {:ok, "status posted"}

                  {:error, reason} ->
                    {:error, reason}
                end

              _ ->
                IO.inspect("Error in posting")
                IO.inspect(decoded)
                {:error, result.status_code}
            end

          {:error, reason} ->
            {:error, reason}
        end
      end
    end
  end
end

defmodule Bot.Mastodon.Actions.PostStatus do
  alias Bot.Mastodon.Auth.ApplicationCredentials
  alias Bot.Mastodon.Auth.UserCredentials
  alias Bot.Mastodon.Actions.UploadImage
  alias Bot.RSS.FoundUrlArchive

  def post(data, token, is_dry_run) do
    case maybe_upload_image(data, is_dry_run) do
      {:ok, media_id} ->
        post_toot(data.id, data.text, media_id, token, is_dry_run)

      {:error, status_code} ->
        {:error, status_code}
    end
  end

  defp maybe_upload_image(data, is_dry_run) do
    case data.media do
      nil ->
        nil

      _ ->
        if is_list(data.media) && length(data.media) > 0 do
          IO.inspect(data)
          IO.inspect("Uploading media to fedi... is dry run? #{is_dry_run}")

          if !is_dry_run do
            token = UserCredentials.get_token()
            fedi_url = ApplicationCredentials.get_fedi_url()
            upload_url = "#{fedi_url}/api/v2/media"

            {:ok, media_id} = UploadImage.upload_image(Enum.at(data.media, 0), upload_url, token)
            IO.inspect("Uploaded media #{media_id} to fedi...")
            # allow procesing of image
            :timer.sleep(4_000)

            IO.inspect("media_id")
            IO.inspect(media_id)

            {:ok, media_id}
          end
        else
          IO.inspect(data)
          IO.inspect("Uploading media to fedi... is dry run? #{is_dry_run}")

          if !is_dry_run do
            token = UserCredentials.get_token()
            fedi_url = ApplicationCredentials.get_fedi_url()
            upload_url = "#{fedi_url}/api/v2/media"

            case UploadImage.upload_image(data.media, upload_url, token) do
              {:ok, media_id} ->
                IO.inspect("Uploaded media to fedi...")
                # allow procesing of image
                :timer.sleep(4_000)
                {:ok, media_id}

              {:error, reason} ->
                {:error, reason}
            end
          end
        end
    end
  end

  defp post_toot(id, text, media_id, token, is_dry_run) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"},
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    form_data =
      cond do
        is_nil(media_id) ->
          %{
            "status" => text
          }

        String.length(String.trim(media_id)) > 0 ->
          %{
            "status" => text,
            "media_ids" => [media_id]
          }
      end

    IO.inspect("About to toot:")
    IO.inspect(form_data)

    request_body = Plug.Conn.Query.encode(form_data)
    was_already_posted = FoundUrlArchive.exists(id)

    cond do
      is_dry_run && was_already_posted ->
        IO.puts("Printing Toot...")
        IO.inspect(request_body)
        IO.inspect(headers)

        if was_already_posted do
          IO.puts("Was already posted!")
        end

        {:ok, "status printed"}

      !is_dry_run && !was_already_posted ->
        reponse =
          HTTPoison.post(
            "#{ApplicationCredentials.get_fedi_url()}/api/v1/statuses",
            request_body,
            headers
          )

        case reponse do
          {:ok, result} ->
            IO.puts("Posting Toot...")
            IO.inspect(result)
            IO.inspect(result.status_code)
            decoded = Jason.decode(result.body)

            case result.status_code do
              200 ->
                IO.inspect("Toot posted!")

                IO.inspect("Archiving ID")
                FoundUrlArchive.add_entry_id(id)

                case decoded do
                  {:ok, body} ->
                    # todo verify 200 ok
                    IO.inspect(body)
                    {:ok, "Toot posted!"}

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

defmodule Bot.Mastodon.Actions.PostStatus do
  alias Bot.Mastodon.Auth.ApplicationCredentials
  alias Bot.Mastodon.Auth.UserCredentials
  alias Bot.Mastodon.Actions.UploadImage

  def post(data, token, is_dry_run) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"},
      {"Accept", "application/json"},
      {"Authorization", token}
    ]

    media_url = maybe_upload_image(data, is_dry_run)

    form_data = %{
      "status" => data.text,
      "media_ids" => [media_url]
    }

    IO.inspect("######### form_data")
    IO.inspect(form_data)
    IO.inspect("######### END  form_data")

    request_body = Plug.Conn.Query.encode(form_data)

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
        {:ok, "status was already posted"}
      else
        IO.inspect("Posting to fedi...")
        IO.inspect("id: #{data.id}")
        IO.inspect("form_data")
        IO.inspect(form_data)
        IO.inspect("request_body")
        IO.inspect(request_body)
        fedi_url = ApplicationCredentials.get_fedi_url()
        reponse = HTTPoison.post("#{fedi_url}/api/v1/statuses", request_body, headers)

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
            :timer.sleep(5_000) # allow procesing of image

            IO.inspect("media_id")
            IO.inspect(media_id)

            media_id
          end
        else
          IO.inspect(data)
          IO.inspect("Uploading media to fedi... is dry run? #{is_dry_run}")

          if !is_dry_run do
            token = UserCredentials.get_token()
            fedi_url = ApplicationCredentials.get_fedi_url()
            upload_url = "#{fedi_url}/api/v2/media"

            {:ok, media_id} = UploadImage.upload_image(data.media, upload_url, token)
            IO.inspect("Uploaded media to fedi...")
            :timer.sleep(5_000) # allow procesing of image

            media_id
          end
        end
    end
  end
end

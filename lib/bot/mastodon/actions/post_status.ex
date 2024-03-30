defmodule Bot.Mastodon.Actions.PostStatus do
  alias Bot.Mastodon.Actions.UploadImage
  alias Bot.RSS.FoundUrlArchive
  require Logger

  def post(data, token) do
    is_dry_run = BotWeb.Api.RssSettings.get_is_dry_run()
    Logger.info("Running dry mode? #{is_dry_run}")

    case FoundUrlArchive.exists(data.id) do
      true ->
        Logger.info("Was already posted!")

        {:ok, "already posted"}

      false ->
        toot_text = format_toot(data)

        case maybe_upload_image(data, is_dry_run) do
          {:ok, media_id} ->
            post_toot(data.id, toot_text, media_id, token, is_dry_run)

          nil ->
            post_toot(data.id, toot_text, nil, token, is_dry_run)

          {:error, status_code} ->
            {:error, status_code}
        end
    end
  end

  defp format_toot(data) do
    content_link =
      cond do
        String.contains?(data.id, "yt:video:") ->
          format_yt_id_to_url(data.id)

        true ->
          data.id
      end

    hashtags_formatted = format_hashtags(data.hashtags)

    case data.id do
      "" ->
        "🤖 💬 \"#{data.text}\""

      _ ->
        "🤖 💬 \"#{data.text}\"

    Source: #{content_link}

    #{hashtags_formatted}
    "
    end
  end

  defp format_yt_id_to_url(id) do
    regex = ~r/yt:video:(.+)/

    match = Regex.run(regex, id)

    case match do
      nil ->
        ""

      _ ->
        yt_url = "https://www.youtube.com/watch?v="
        yt_video_id = List.last(match)
        "#{yt_url}#{yt_video_id}"
    end
  end

  defp format_hashtags(hashtags_as_string) do
    hashtags_normalized =
      case hashtags_as_string do
        value when is_binary(value) ->
          case String.length(String.trim(value)) >= 1 do
            true ->
              value

            false ->
              ""
          end

        value when is_nil(value) ->
          ""

        _ ->
          ""
      end

    case String.trim(hashtags_normalized) do
      "" ->
        ""

      _ ->
        String.split(hashtags_normalized, ",")
        |> Enum.map(fn it -> String.trim(it) end)
        |> Enum.map(fn it -> "##{it}" end)
        |> Enum.join(" ")
    end
  end

  defp maybe_upload_image(data, is_dry_run) do
    case data.media do
      nil ->
        {:ok, nil}

      _ ->
        if is_list(data.media) && length(data.media) > 0 do
          Logger.info("Uploading media to fedi... is dry run? #{is_dry_run}")

          if !is_dry_run do
            credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
            token = credentials.user_token
            fedi_url = credentials.fedi_url

            upload_url = "#{fedi_url}/api/v2/media"

            {:ok, media_id} = UploadImage.upload_image(Enum.at(data.media, 0), upload_url, token)
            Logger.info("Uploaded media #{media_id} to fedi...")
            # allow procesing of image
            :timer.sleep(4_000)

            {:ok, media_id}
          end
        else
          Logger.info("Uploading media to fedi... is dry run? #{is_dry_run}")

          if !is_dry_run do
            credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
            token = credentials.user_token
            fedi_url = credentials.fedi_url

            upload_url = "#{fedi_url}/api/v2/media"

            case UploadImage.upload_image(data.media, upload_url, token) do
              {:ok, media_id} ->
                Logger.info("Uploaded media to fedi...")
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

    Logger.info("Encoding toot...")

    request_body = Plug.Conn.Query.encode(form_data)

    case is_dry_run do
      true ->
        Logger.info("Printing Toot...")
        IO.inspect(request_body)
        IO.inspect(headers)

        if id != "" do
          FoundUrlArchive.add_entry_id(id)
        end

        Bot.Events.add_event(Bot.Events.new_event("Printed toot to debug output in terminal! (dry run is on)", "Info"))
        {:ok, "status printed"}

      false ->
        Logger.info("Posting Toot...")

        credentials = Bot.Mastodon.Auth.PersistCredentials.get_credentials()
        fedi_url = credentials.fedi_url

        reponse =
          HTTPoison.post(
            "#{fedi_url}/api/v1/statuses",
            request_body,
            headers
          )

        case reponse do
          {:ok, result} ->
            Logger.info("Response status:")
            IO.inspect(result.status_code)
            decoded = Jason.decode(result.body)

            case result.status_code do
              200 ->
                Logger.info("Toot posted!")

                Logger.info("Archiving ID...")

                if id != "" do
                  FoundUrlArchive.add_entry_id(id)
                end

                case decoded do
                  {:ok, _body} ->
                    msg = "OK Posted new RSS toot"
                    event = Bot.Events.new_event(msg, "Info")
                    Bot.Events.add_event(event)

                    {:ok, "Toot posted!"}

                  {:error, reason} ->
                    msg = "WARN Could not post toot.\r\n #{reason}"
                    event = Bot.Events.new_event(msg, "Warning")
                    Bot.Events.add_event(event)
                    {:error, reason}
                end

              _ ->
                msg = "WARN Could not post toot. Status code from POST /api/v1/statuses #{result.status_code}"
                event = Bot.Events.new_event(msg, "Warning")
                Bot.Events.add_event(event)
                Logger.warn("Error in posting")
                IO.inspect(decoded)
                {:error, result.status_code}
            end

          {:error, reason} ->
            msg = "Something went wrong posting a RSS toot:\r\n #{reason}"
            Logger.warn("Error in posting\r\n #{reason}")

            event = Bot.Events.new_event(msg, "Error")
            Bot.Events.add_event(event)

            {:error, reason}
        end
    end
  end
end

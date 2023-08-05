defmodule Bot.Mastodon.Actions.UploadImage do
  require Logger

  def upload_image(media_url, upload_endpoint, token) do
    Logger.info("Loading image from URL: #{media_url}")

    mime_type = MIME.from_path(media_url)
    IO.inspect(mime_type)
    Logger.info("Detected MIME type: #{mime_type}")

    case HTTPoison.get(media_url) do
      {:ok, %{body: body}} ->
        temp_file_path = "temp_file"
        File.write!(temp_file_path, body)

        Logger.info("Uploading image to endpoint: #{upload_endpoint}")

        headers = [
          {"Content-Type", "multipart/form-data"},
          {"Authorization", token},
          {"Accept", "application/json"}
        ]

        post_upload_response =
          HTTPoison.post(upload_endpoint, {:multipart, [{:file, temp_file_path}]}, headers)

        case post_upload_response do
          {:ok, %{body: body, status_code: status_code}} ->
            decoded = Jason.decode!(body)
            IO.inspect(decoded)
            Logger.info("status code img upload#{status_code}")
            IO.inspect(Map.get(decoded, "id", nil))

            case status_code do
              x when x in 200..299 ->
                Logger.info("ok when ")
                {:ok, Map.get(decoded, "id", nil)}

              202 ->
                Logger.info("ok 202 ")
                {:ok, Map.get(decoded, "id", nil)}

              _ ->
                Logger.warn("image upload failed")
                {:error, status_code}
            end

          {:error, %HTTPoison.Error{reason: reason}} ->
            {:error, reason}

          _ ->
            {:error, "Unknown error"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      _ ->
        {:error, "Unknown error"}
    end
  end
end

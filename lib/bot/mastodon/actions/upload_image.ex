defmodule Bot.Mastodon.Actions.UploadImage do
  require Logger

  def upload_image(media_url, upload_endpoint, token) do
    Logger.debug("Loading image from URL: #{media_url}")

    mime_type = MIME.from_path(media_url)
    IO.inspect(mime_type)
    Logger.debug("Detected MIME type: #{mime_type}")

    case HTTPoison.get(media_url) do
      {:ok, %{body: body}} ->
        temp_file_path = "temp_file"
        File.write!(temp_file_path, body)

        Logger.debug("Uploading image to endpoint: #{upload_endpoint}")

        headers = [
          {"Content-Type", "multipart/form-data"},
          {"Authorization", token},
          {"Accept", "application/json"}
        ]

        post_upload_response =
          HTTPoison.post(upload_endpoint, {:multipart, [{:file, temp_file_path}]}, headers)

        case post_upload_response do
          {:ok, %{body: body}} ->
            decoded = Jason.decode!(body)
            IO.inspect(decoded)

           IO.inspect(Map.get(decoded, "id", nil))
            {:ok, Map.get(decoded, "id", nil)}

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

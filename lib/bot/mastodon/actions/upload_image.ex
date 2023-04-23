defmodule Bot.Mastodon.Actions.UploadImage do
  require Logger

  def upload_image(url_remote, upload_url, token) do
    Logger.debug("Loading image from URL: #{url_remote}")

    mime_type = MIME.from_path(url_remote)
    Logger.debug("Detected MIME type: #{mime_type}")

    case HTTPoison.get(url_remote) do
      {:ok, %{body: body}} ->
        File.write("temp.jpeg", body)

        Logger.debug("Uploading image to endpoint: #{upload_url}")

        headers = [
          {"Content-Type", "multipart/form-data"},
          {"Authorization", token},
          {"Accept", "application/json"}
        ]

        response =
          HTTPoison.post(
            upload_url,
            %{
              file: {:file, "temp.jpeg", mime_type}
            },
            headers,
            timeout: 30_000
          )

        case response do
          {:ok, %{body: body}} ->
            decoded = Jason.decode!(body)
            IO.inspect(decoded)
            IO.puts(decoded.url)
            decoded.id
            {:ok, decoded.id}

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

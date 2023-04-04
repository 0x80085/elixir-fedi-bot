defmodule Bot.Mastodon.Auth.PersistCredentials do
  @file_path "credentials.json"

  def get_from_file() do
    case File.read(@file_path) do
      {:ok, contents} ->
        case Jason.decode(contents) do
          {:ok, creds} ->
            creds

          {:error, reason} ->
            IO.puts("failed to read credentials")
            IO.puts(reason)
            nil
        end

      {:error, :enoent} ->
        IO.puts("File #{@file_path} not found")
        nil
    end
  end

  def has_stored_credentials do
    File.exists?(@file_path)
  end

  def clear_stored_credentials do
    File.rm(@file_path)
  end

  def persist_credentials(credentials) do
    encoded = Jason.encode!(credentials)

    file = File.open!(@file_path, [:write])

    IO.write(file, encoded)
  end
end

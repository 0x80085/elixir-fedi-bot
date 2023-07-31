defmodule Bot.Mastodon.Auth.PersistCredentials do
  @file_path "credentials.json"
  require Logger

  def get_from_file() do
    case File.read(@file_path) do
      {:ok, contents} ->
        case Jason.decode(contents) do
          {:ok, creds} ->
            creds

          {:error, reason} ->
            Logger.error("failed to read credentials")
            Logger.error(reason)
            nil
        end

      {:error, :enoent} ->
        Logger.warn("File #{@file_path} not found")
        nil
    end
  end

  def has_stored_credentials do
    File.exists?(@file_path)
  end

  def clear_stored_credentials do
    File.rm(@file_path)
  end

  def encode_and_persist(credentials) do
    encoded = Jason.encode!(credentials)
    prettified = Jason.Formatter.pretty_print(encoded)

    file = File.open!(@file_path, [:write])
    IO.write(file, prettified)
  end
end

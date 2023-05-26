
defmodule Bot.Chatgpt.CredentialsWrite do
  @file_path "chatgpt-credentials.json"

  @spec get_from_file :: any
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

      _ ->
        IO.puts("Something went wrong in get_from_file")
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

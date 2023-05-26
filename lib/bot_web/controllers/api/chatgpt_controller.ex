defmodule BotWeb.Api.ChatgptController do
  use BotWeb, :controller

  def get_has_credentials(conn, _params) do
    json(conn, Bot.Chatgpt.CredentialsWrite.has_stored_credentials())
  end

  def set_secret_key(conn, params) do
    Bot.Chatgpt.CredentialStore.set_secret_key(params["secret_key"])

    secret_key = Bot.Chatgpt.CredentialStore.get_secret_key()

    Bot.Chatgpt.CredentialsWrite.encode_and_persist(%{secret_key: secret_key})

    send_resp(conn, :ok, "")
  end

  def delete_secret_key(conn, _params) do
    Bot.Chatgpt.CredentialsWrite.clear_stored_credentials()
    Bot.Chatgpt.CredentialStore.set_secret_key(nil)
    send_resp(conn, :no_content, "")
  end

  def chat(conn, params) do
    {:ok, answer} = Bot.Chatgpt.ChatActions.chat_with_gpt(params["text"])
    Jason.encode!(answer)
    json(conn, answer)
  end
end

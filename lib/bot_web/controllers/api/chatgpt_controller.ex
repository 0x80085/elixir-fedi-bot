defmodule BotWeb.Api.ChatgptController do
  use BotWeb, :controller

  def get_has_credentials(conn, _params) do
    json(conn, Bot.Chatgpt.CredentialsWrite.has_stored_credentials())
  end

  def set_secret_key(conn, params) do
    Bot.Chatgpt.CredentialsWrite.encode_and_persist(params["secret_key"])
    json(conn, Bot.Chatgpt.CredentialStore.set_secret_key(params["secret_key"]))
  end

  def delete_secret_key(conn, _params) do
    Bot.Chatgpt.CredentialsWrite.clear_stored_credentials()
    Bot.Chatgpt.CredentialStore.set_secret_key(nil)
    send_resp(conn, :no_content, "")
  end
end

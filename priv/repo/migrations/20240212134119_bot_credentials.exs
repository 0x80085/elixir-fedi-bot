defmodule Bot.Repo.Migrations.BotCredentials do
  use Ecto.Migration

  def change do
    create table(:bot_credentials) do
      add :account_id, :string
      add :app_token, :string
      add :client_id, :string
      add :client_secret, :string
      add :fedi_url, :string
      add :user_token, :string
    end
  end
end

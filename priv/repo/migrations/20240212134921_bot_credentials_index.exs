defmodule Bot.Repo.Migrations.BotCredentialsIndex do
  use Ecto.Migration

  def change do
    create unique_index(:bot_credentials, [:account_id])
  end
end

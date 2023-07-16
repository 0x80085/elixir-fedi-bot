defmodule Bot.Repo.Migrations.CreateRssUrls do
  use Ecto.Migration

  def change do
    create table(:rss_urls) do
      add :url, :string
      add :is_enabled, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:rss_urls, [:url])
  end
end

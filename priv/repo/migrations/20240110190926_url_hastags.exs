defmodule Bot.Repo.Migrations.UrlHastags do
  use Ecto.Migration

  def change do
    alter table("rss_urls") do
      add :hastags, :text
    end
  end
end

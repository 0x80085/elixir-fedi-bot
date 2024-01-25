defmodule Bot.Repo.Migrations.UrlHashtags do
  use Ecto.Migration

  def change do
    alter table("rss_urls") do
      remove_if_exists :hastags, :text
      add :hashtags, :text
    end
  end
end

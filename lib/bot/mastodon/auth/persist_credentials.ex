defmodule Bot.Mastodon.Auth.PersistCredentials do
  import Ecto.Query, warn: false
  alias Bot.Repo
  require Logger

  def get_all do
    from(c in Bot.BotCredentialsRepo, select: c)
    |> Repo.all()
  end

  def get_by_id(id) do
    Repo.get_by(Bot.BotCredentialsRepo, account_id: id)
  end

  def insert(attrs) do
    %Bot.BotCredentialsRepo{}
    |> Bot.BotCredentialsRepo.changeset(attrs)
    |> Bot.Repo.insert()
  end

  def update_by_id(id, attrs) do
    get_by_id(id)
    |> Bot.BotCredentialsRepo.changeset(attrs)
    |> Bot.Repo.update()
  end

  def delete_by_id(id) do
    get_by_id(id)
    |> Bot.Repo.delete()
  end

  def delete_all() do
    from(c in Bot.BotCredentialsRepo, select: c)
    |> Bot.Repo.delete_all()
  end
end

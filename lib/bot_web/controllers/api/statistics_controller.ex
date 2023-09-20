defmodule BotWeb.Api.StatisticsController do
  use BotWeb, :controller

  def get_frequency(conn, _params) do
    json(conn, Bot.Mastodon.Statistics.Frequency.average_of_toots_per_hour_last_24h())
  end

  def get_engagements(conn, _params) do
    json(conn, Bot.Mastodon.Statistics.Engagements.total_engagements_last_24h())
  end

  def get_account_info(conn, _params) do
    json(conn, Bot.Mastodon.Statistics.AccountInfo.account_info())
  end
end

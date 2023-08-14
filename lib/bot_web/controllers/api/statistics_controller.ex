defmodule BotWeb.Api.StatisticsController do
  use BotWeb, :controller

  def get_frequency(conn, _params) do
    json(conn, Bot.Mastodon.Statistics.Frequency.calculate_toot_frequency())
  end
end

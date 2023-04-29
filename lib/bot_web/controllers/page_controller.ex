defmodule BotWeb.PageController do
  use BotWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def rss(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :rss, layout: false)
  end
end

defmodule BotWeb.PageController do
  use BotWeb, :controller

  @spec home(Plug.Conn.t(), any) :: Plug.Conn.t()
  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  @spec rss(Plug.Conn.t(), any) :: Plug.Conn.t()
  def rss(conn, _params) do
    render(conn, :rss, layout: false)
  end

  @spec statistics(Plug.Conn.t(), any) :: Plug.Conn.t()
  def statistics(conn, _params) do
    render(conn, :statistics, layout: false)
  end
end

defmodule BotWeb.PageController do
  use BotWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  @spec rss(Plug.Conn.t(), any) :: Plug.Conn.t()
  def rss(conn, _params) do
    render(conn, :rss, layout: false)
  end

  def chatgpt(conn, _params) do
    render(conn, :chatgpt, layout: false)
  end
end

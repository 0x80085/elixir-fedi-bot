defmodule BotWeb.PageController do
  use BotWeb, :controller

  @spec home(Plug.Conn.t(), any) :: Plug.Conn.t()
  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end

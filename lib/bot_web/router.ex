defmodule BotWeb.Router do
  use BotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BotWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BotWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api", BotWeb do
    pipe_through :api

    # Setup the bot / connect to a mastodon instance
    get "/setup", TestController, :connect_application
    # Connect masto user to bot application
    get "/connect_user", TestController, :connect_user
    # Post status/toot/poast/shitpost
    get "/post", TestController, :post_status


    ## Util
    # Test RSS fetcher
    get "/test", TestController, :test_rss_route
    # Get application token
    get "/token", TestController, :get_token
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bot, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BotWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

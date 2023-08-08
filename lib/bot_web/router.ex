defmodule BotWeb.Router do
  use BotWeb, :router

  import BotWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BotWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :fetch_current_user
  end

  scope "/", BotWeb do
    # pipe_through :browser
    pipe_through [:browser, :require_authenticated_user]

    get "/", PageController, :home
    get "/rss", PageController, :rss
    get "/chatgpt", PageController, :chatgpt
  end

  # Other scopes may use custom stacks.
  scope "/api", BotWeb do
    pipe_through [:api, :require_authenticated_user]

    # bot setup
    get "/setup", Api.AuthController, :connect_application
    get "/connect_user", Api.AuthController, :connect_user
    get "/has_credentials", Api.AuthController, :has_credentials

    # bot reset
    delete  "/app/credentials", Api.AuthController, :delete_app_credentials
    delete  "/bot/credentials", Api.AuthController, :delete_bot_credentials

    # Post status or toot
    post "/post", Api.ActionsController, :post_status
    # Preview status or toot
    get "/preview", Api.ActionsController, :preview_status

    # RSS
    get "/rss/urls", Api.RssController, :get_rss_urls
    post "/rss/urls", Api.RssController, :add_url
    patch "/rss/urls", Api.RssController, :set_is_enabled
    post "/rss/job", Api.RssController, :trigger_fetch_job_and_print
    put "/rss/settings/is_dry_run", Api.RssController, :set_is_dry_run
    get "/rss/settings/is_dry_run", Api.RssController, :get_is_dry_run
    get "/rss/settings/scrape_interval", Api.RssController, :get_scrape_interval
    put "/rss/settings/scrape_interval", Api.RssController, :set_scrape_interval
    get "/rss/settings/max_age", Api.RssController, :get_scrape_max_age
    put "/rss/settings/max_age", Api.RssController, :set_scrape_max_age
    get "/rss/settings/max_post_burst_amount", Api.RssController, :get_max_post_burst_amount
    put "/rss/settings/max_post_burst_amount", Api.RssController, :set_max_post_burst_amount

    # Chatgpt
    get "/chatgpt/credentials", Api.ChatgptController, :get_has_credentials
    post "/chatgpt/credentials", Api.ChatgptController, :set_secret_key
    delete "/chatgpt/credentials", Api.ChatgptController, :delete_secret_key

    post "/chatgpt/chat", Api.ChatgptController, :chat

    ## Util
    # Test RSS fetcher
    get "/test", Api.TestController, :test_rss_route
    # Get application token
    get "/token", Api.AuthController, :get_token
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  # if Application.compile_env(:bot, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:browser, :require_authenticated_user]

      live_dashboard "/dashboard", metrics: BotWeb.Telemetry
      # forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  # end

  ## Authentication routes

  scope "/", BotWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BotWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BotWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BotWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", BotWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BotWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end

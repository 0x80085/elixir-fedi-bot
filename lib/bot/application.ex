defmodule Bot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BotWeb.Telemetry,
      # Start the Ecto repository
      Bot.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bot.PubSub},
      # Start Finch
      {Finch, name: Bot.Finch},
      # Start the Endpoint (http/https)
      BotWeb.Endpoint,
      # Start a worker by calling: Bot.Worker.start_link(arg)
      # {Bot.Worker, arg}

      # RSS post and fetch CRON GenServer
      Bot.RSS.Cron,

      # Agents aka data stores
      Bot.Chatgpt.CredentialStore,
      Bot.Mastodon.Auth.ApplicationCredentials,
      Bot.Mastodon.Auth.UserCredentials,
      Bot.RSS.FoundUrlArchive,
      Bot.RSS.RssUrlsStore,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, opts)

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

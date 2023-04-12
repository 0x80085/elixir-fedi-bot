# Fedi Bot

To start your Bot / Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To connect the bot to your fedi account, follow the instructions on http://localhost:4000


# Todo 

- [x] Persist tokens gotten from fedi
- [ ] Refresh token if expired
- [ ] Add CRON job to read and re-post RSS feeds
- [ ] Login protect dev/dashboard 
- [ ] Login protect connect fedi account page
- [ ] Track/save posts to DB to prevents dupes and just for archiving
- [ ] Grab video link from nitter/twitter and add to twoot 

# ideas to repost

- livechart anime releases
- anti china news 
- new tommy G YT vids
- (new rev says desu YT vids)
- new trap geek YT vids
- new IRLMoments or irlm2 YT vids
- twitter censoredgaming_
- krebs on sec

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix



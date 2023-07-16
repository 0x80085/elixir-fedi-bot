# Fedi Bot

To start your Bot / Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To connect the bot to your fedi account just register and login, then follow the instructions on http://localhost:4000

# Todo 

- [x] Persist tokens gotten from fedi
- [x] Post text + image
- ~~Refresh token if expired (cant ? at least not user token w/o interaction from user)~~
- [x] Login protect dev/dashboard 
- [x] Login protect connect fedi account page
- [x] Enter fedi url to connect to 
- [x] Ability to update/reset bot fedi config (delete the credentials.json file + clear agent states)
- [x] Grab image link from nitter/twitter and add to twoot 
- [x] Trigger RSS reposter job from ui 
- [x] Add CRON job to read and re-post RSS feeds
- [x] Track/save posts in memory to prevent dupes
- [x] Add ChatGPT API key
- [x] Ask ChatGPT and see result in ui
- [x] Block registration after 1 user signed up (becomes admin this way)
- [x] Make deploy/publish ready if needed (scripts etc.?)
- [ ] Enter fedi url from pleroma or soapbox or misskey or other popular fediware (needs more code, wont be just oauth I think...)   
- [ ] Grab video from nitter/twitter and add to twoot 
- [ ] Manage + put in DB: 
  - [ ] Dry run mode
  - [ ] Toot formatting template (the 🤖💬 "your text here> \n Source:# ")
  - [ ] Scrape interval in ms
  - [ ] On/off RSS URLs
  - [ ] Max post burst count 
  - [ ] Track/save posts to prevent dupes
- [ ] Use Logger.debug instead of IO.* for logging important messages

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix



# Fedi Bot

Make sure you have created a PostgreSQL DB with credentials found in `config/dev.exs`.

To start your Bot / Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To connect the bot to your any Mastodon account
- register and login
- then follow the instructions on http://localhost:4000

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
- [x] Use Logger.info instead of IO.* for logging important messages
- [ ] Enter fedi url from pleroma or soapbox or misskey or other popular fediware (needs more code, wont be just oauth I think...)   
- [ ] ~~Grab video from nitter/twitter and add to twoot~~
- [ ] Manage + put in DB: 
  - [x] RSS URLs
  - [x] Dry run mode
  - [x] Scrape interval in ms
  - [x] Max post burst count
  - [x] Fedi account creds
  - [ ] Toot formatting template (the 🤖💬 "your text here \n Source:# ")
  - [ ] ~~Track/save posts to prevent dupes~~ unneeded imo, causes max 1 or 2 doubles per restart (rare) on current im memory strategy
- [ ] add/remove hashtags to certain posts from certain rss feeds
- [ ] ~~file upload limit backend 2Mb~~ instead show error somewhere when upload img failed
- [x] error handling rss fetcher or w/e causes it to sometimes crash
- [x] remove chatgpt impl
- [x] rss scrape log per url
- [x] better rss page ui
- [ ] ~~privategpt?~~
- [x] mastodon account info display like username
- [ ] ~~fix bug w manual scrape if still there~~
- [x] post page improve ui
- [x] also filter out the ones that are already posted before uploading img etc 
- [x] post stats
    - [x] avg posts per h today
    - [x] post engagements today
- [ ] allow multiple bots per fedichan instance 
- [ ] make monitizable by subcsription model
- [ ] find more stats to show
- [ ] Better post fail feedback when posting from bot page (ex. img upload fails sometimes bc too big) 

## Deploy

check the `/deploy` folder for scripts.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Some RSS URLs

    LiveChart.me aka anime news stuff
    Feed of anime episodes that have aired in the last 24 hours
    "https://www.livechart.me/feeds/episodes",

    Feed of the latest anime headlines curated by the LiveChart.me team
    "https://www.livechart.me/feeds/headlines",

    youtube channels feeds
    IRLM2
    "https://www.youtube.com/feeds/videos.xml?channel_id=UC3oh3hI5xteovwFRAwG0qwQ",
    CensoredGaming
    "https://www.youtube.com/feeds/videos.xml?channel_id=UCFItIX8SIs4zqhJCHpbeV1A",

    cybersec news
    "https://feeds.feedburner.com/TheHackersNews",
    "https://krebsonsecurity.com/feed", ⚠️ errors
    "https://www.bleepingcomputer.com/feed",
    "https://www.darkreading.com/rss.xml",
    "https://www.upguard.com/breaches/rss.xml",
    "https://www.databreaches.net/feed/",
    "https://threatpost.com/feed"

    Twitter rss
    censoredgaming
    "https://nitter.snopyta.org/censoredgaming_/rss",
    some vr chat club
    "https://nitter.snopyta.org/MONDAY_RELIEF/rss",
    some japan night club mogra
    "https://nitter.snopyta.org/MOGRAstaff/rss"



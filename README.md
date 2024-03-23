# Fediverse Bot

Make sure you have created a PostgreSQL DB with credentials found in `config/dev.exs`.

To start your Bot / Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To connect the bot to your any Mastodon account
- register and login
- then follow the instructions on http://localhost:4000

# Features 

- Scrapes RSS feeds and posts
- Control your bot from the browser
- Mastodon & Pleroma support
- Manually post toot + image
  - Preview toot before posting (does not contain full featuresof a regular toot) 
- 1 bot per fedibotchan process/DB
- Multiple RSS feed support
- Bot statistics
  - avg % of amount of toots per hour 
  - amount of favs, retoots, comments last 24 hours 
  - follower count
  - account age
  - total toot count
  - total toot count
- Real time visual log of RSS scrape results
- Configurable RSS scrape job settings
  - max_post_burst max # toots per URL scrape job (e.g. if max_post_burst is 5 and there are 7 new posts for example.com/rss, it wil post the 5 most recent ones)
  - Scrape job interval in (scrape every x minutes)
  - Max age of RSS item (e.g. can't be posted more than x minites ago)
  - Dry run mode: prints toots to terminal output instead of posting
- 

# Todo 

- [x] Persist tokens gotten from fedi
- [x] Post text + image
- [x] Login protect dev/dashboard 
- [x] Login protect connect fedi account page
- [x] Enter fedi url to connect to 
- [x] Ability to update/reset bot fedi config (delete the credentials.json file + clear agent states)
- [x] Trigger RSS reposter job from ui 
- [x] Add CRON job to read and re-post RSS feeds
- [x] Track/save posts in memory to prevent dupes
- [x] Block registration after 1 user signed up (becomes admin this way)
- [x] Make deploy/publish ready if needed (scripts etc.?)
- [x] Use Logger.info instead of IO.* for logging important messages
- [x] Enter fedi url from pleroma or soapbox  or other popular fediware
        ~~(needs more code, wont be just oauth I think...)~~ Just wroks it seems!  
- [ ] ~~Grab video from nitter/twitter and add to twoot~~
- [ ] Manage + put in DB: 
  - [x] RSS URLs
  - [x] Dry run mode
  - [x] Scrape interval in ms
  - [x] Max post burst count
  - [x] Fedi account creds
  - [ ] Toot formatting template (the 🤖💬 "your text here \n Source:# ")
  - [ ] ~~Track/save posts to prevent dupes~~ unneeded imo, causes max 1 or 2 doubles per restart (rare) on current in memory strategy
- [x] add/remove hashtags to certain posts from certain rss feeds
- [ ] ~~file upload limit backend 2Mb~~ instead show error somewhere when upload img failed
- [x] error handling rss fetcher or w/e causes it to sometimes crash
- [x] remove chatgpt impl
- [x] rss scrape log per url
- [x] better rss page ui
- [x] mastodon account info display like username
- [x] post page improve ui
- [x] also filter out the ones that are already posted before uploading img etc 
- [x] post stats
    - [x] avg posts per h today
    - [x] post engagements today
- [x] allow deleting rss source
- [x] test page for rss source to see if it'll error or not
- [ ] allow multiple bots per fedichan instance 
- [ ] find more stats to show
- [ ] Better post fail feedback when posting from bot page (ex. img upload fails sometimes bc too big) 
- [ ] Enter fedi auth key from misskey
- [ ] show next up RSS scrape URL in RSS 'start scrape job' section 
  - implementing this surfaced a problem, the corn state cannot be accessed, need to use seperate agent to save the state probs
- [ ] Stats engagements is not reliable when thep posts fetched are not the ones interacted with
    - Base on other things like notfications? if possible
    
## Package for deploy

Use the ´./publish.sh´ script to ZIP the project suited for sending to your server.  

## Migrate DB

Use the ´./migrate.sh´ script to update the DB in case there are pending database model updates for your local instance. 

## Deploy

check the `/deploy` folder for scripts.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


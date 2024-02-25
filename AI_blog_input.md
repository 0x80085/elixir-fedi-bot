You will write a wordpress artoicle in theme of a devlog  for a fediverse bot project 

its  mastodon bot 

the current prototype, available at https://mas.to/@whyismythirdeye posts about upcoming anime media releases, cybersecurity news topics, gaming censorship news. It scrapes RSS feeds and reposts the reulsts.

its in closed aplha , source is closed, only works for mastodon and is in active development 

write  the article based on these commits they are in latest top to oldest bottom order 

 enable os_mon to see OS related data in the built)in admin dashboard of elixir phoenix https://hexdocs.pm/phoenix_live_dashboard/os_mon.html
c72c521 pt.2.2 Bot.Mastodon.Auth.ApplicationCredentials is also not agent anymore so removing  credentials memory caching is completed!
89d4a7e pt 2.1 multi bot - no more being a elixir agent for user_credentials module Also fix bug where clear bot credentials feature didnt work after last commit
9c571cf UI copywrite - improve events log description using AI suggestions
3d15a33 pt 1 of moving to multi bot support move credentials to DB and out of agents' cache, also consoldiate mastodon user and mastodon app data into just 'credentials' concept
0044f2c ui add @ to username on stats page
5aaee0f cleanup
634ba42 fix bug where after startup the user info cache is empty
19025a4 Toast feedback when test toot succesful  Toast feedback when connect Account success
dc01f3f Toast feedback when update RSS scraper settings success + various small UI irmporvements for RSS page (buttons, la
bels, inputs, spacings, colors, copywriting)
ee9f751 add toast feedback function
d9bdce2 sort list of rss urls to be scraped alphabetically on RSS config page
11043a4 Include mentions in total engagements last 24 count on stats page
3c59871 Fix credentials cache empty on restart - get from DB on  ApplicationCredentials cache init
5efa65e Take out already posted RSS news items before limiting max_post_burst  when posting from RSS CRON job
ac3de84 DB model
600d7bd check todo item
2632f09 update todo list
248bcf7 persist mastodon tokens in db


The bot profile on mastodon is the following --------



📰 gaijin.news.bot :bot:
@whyismythirdeye@mas.to
Automated

Hittin' the digital road! 🚴‍♂️🗞️

Anime & cybersecurity scoops from:

🖱️ thehackernews
🖥️ bleepingcomputer
🍙 livechart
🌀 packetstormsecurity

Curating the digital landscape where cybersecurity and anime news converge. 🌐🤖



--------------------------------

based on the previous input generate the following; 

a wordpress SEO optimized title 
a wordpress SEO optimized article body 
a wordpress SEO optimized article SEO tags 
a wordpress SEO optimized article SEO description  

focus on the follwoing: 
..... insert focus poiints
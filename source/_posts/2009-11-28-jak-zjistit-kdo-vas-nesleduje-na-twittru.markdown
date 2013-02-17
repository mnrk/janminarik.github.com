---
layout: post
title: "Jak zjistit, kdo vás nesleduje na Twittru"
date: 2009-11-28 19:49
comments: true
categories:
---

Skript v Ruby, který vypíše vámi sledované lidi na Twitteru, kteří nesledují vás.

Chcete sledovat jen ty, kteří sledují vás? Máte nainstalované Ruby? Tenhle skript vypíše ty z vámi sledovaných, kteří nesledují vás:

Pro správnou funkčnost je třeba mít nainstalované Ruby včetně Rubygems a twitter gem se všemi závislostmi:

``` bash
    sudo gem install twitter
```

Následující kód vypíše seznam těch, kteří vás nesledují, v tom pořadí, v jakém je uvidíte na Twitteru v seznamu followed. Místo xxxxxx a yyyyyy doplňte svůj login a heslo:

``` ruby
username = "xxxxx"
password = "yyyyy"

require 'rubygems'
require 'twitter'

base = Twitter::Base.new Twitter::HTTPAuth.new(username, password)
not_following = base.friend_ids - base.follower_ids

puts "Total followed not following you: #{not_following.size}"

not_following.each do |user_id|
  user = base.user(user_id)
  puts "#{user.name} (following: #{user.friends_count}, followers: #{user.followers_count})"
end
```
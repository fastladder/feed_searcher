# FeedSearcher
Search RSS feed URLs from the given URL.


## Installation
```
$ gem install feed_searcher
```


## Usage
```ruby
require "feed_searcher"
FeedSearcher.search("https://github.com/r7kamura/feed_searcher")
#=> ["https://github.com/r7kamura/feed_searcher/commits/master.atom"]
```

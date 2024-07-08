# FeedSearcher 
Search RSS feed URLs from the given URL.

## Installation
```
$ gem install feed_searcher
```


## Usage
```ruby
require "feed_searcher"

FeedSearcher.search("https://github.com/fastladder/feed_searcher")
#=> ["https://github.com/fastladder/feed_searcher/commits/master.atom"]

FeedSearcher.search("https://github.com/fastladder/feed_searcher/commits/master.atom")
#=> ["https://github.com/fastladder/feed_searcher/commits/master.atom"]
```


## Internal
Let me explain how FeedSearcher works along its execution sequence.

1. Fetches the HTML source of the given URL
2. Finds link elements (represented as XPath format)
3. Extracts URLs from the elements via its `href` attribute
4. Includes the given URL if its resource itself is a feed
5. Converts from relative path to absolute path

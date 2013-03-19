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


## Internal
Let me explain how FeedSearcher works along its execution sequence.

1. Fetches the HTML source of the given URL
2. Finds link elements (represented as XPath format)
3. Extracts URLs from the elements via its `href` attribute
4. Include the given URL if its resource itself is a feed
5. Converts to relative path to absolute path

FeedSearcher finds link elements matcing following XPath patterns.

* //link[@rel='alternate'][@type='application/atom+xml']
* //link[@rel='alternate'][@type='application/rdf+xml']
* //link[@rel='alternate'][@type='application/rss+xml']

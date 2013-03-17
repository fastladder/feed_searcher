require "feed_searcher/version"
require "feed_searcher/fetcher"
require "feed_searcher/page"
require "uri"
require "mechanize"
require "nokogiri"

class FeedSearcher
  def self.search(*args)
    new(*args).search
  end

  attr_reader :options, :url

  def initialize(url, options = {})
    @url     = url
    @options = options
  end

  def search
    fetch.feed_urls.map {|feed_url| URI.join(url, feed_url).to_s }
  end

  private

  def fetch
    Fetcher.fetch(url, options)
  end
end

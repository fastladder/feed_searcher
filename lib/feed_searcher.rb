require "feed_searcher/version"
require "feed_searcher/fetcher"
require "feed_searcher/page"
require "mechanize"

class FeedSearcher
  Error                = Class.new(StandardError)
  InvalidResponseError = Class.new(Error)

  def self.search(*args)
    new(*args).search
  end

  attr_reader :options, :url

  def initialize(url, options = {})
    @url     = url
    @options = options
  end

  def search
    if page.html?
      page.feed_urls
    else
      raise InvalidResponseError
    end
  end

  private

  def fetch
    Fetcher.fetch(url, options)
  end

  def page
    @page ||= fetch
  end
end

require 'uri'

class FeedSearcher
  class Page
    attr_reader :url, :page

    def initialize(url, page)
      @url  = url
      @page = page
    end

    def feed_urls
      feed_attributes.map {|attribute| URI.join(url, attribute["href"]).to_s }
    end

    private

    def feed_attributes
      root.xpath("//link[@type='application/rss+xml' or @type='application/atom+xml']")
    end

    def root
      Nokogiri.HTML(page.body)
    end
  end
end

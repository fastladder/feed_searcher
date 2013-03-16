class FeedSearcher
  class Page
    attr_reader :page

    def initialize(page)
      @page = page
    end

    def html?
      page.is_a?(Mechanize::Page)
    end

    def feed_urls
      feed_attributes.map {|attribute| attribute["href"] }
    end

    private

    def feed_attributes
      root.xpath("//link[@type='application/rss+xml' or @type='application/atom+xml']")
    end

    def root
      page.root
    end
  end
end

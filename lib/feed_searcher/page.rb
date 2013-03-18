class FeedSearcher
  class Page
    MIME_TYPES = %w[
      application/atom+xml
      application/rdf+xml
      application/rss+xml
    ]

    attr_reader :page

    def initialize(page)
      @page = page
    end

    def feed_urls
      feeds = feed_attributes.map {|attribute| attribute["href"] }
      content_type = page.response["content-type"]
      if content_type && MIME_TYPES.include?(content_type.gsub(/;.*$/, ""))
        feeds << page.uri.to_s
      end
      feeds
    end

    private

    def feed_attributes
      root.xpath("//link[@rel='alternate' and (#{types_query})]")
    end

    def types_query
      MIME_TYPES.map {|type| "@type='#{type}'" }.join(" or ")
    end

    def root
      Nokogiri.HTML(page.body)
    end
  end
end

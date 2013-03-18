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
      urls = []
      urls << page.uri if is_feed?
      urls.concat feed_attributes.map {|attribute| attribute["href"] }
    end

    private

    def is_feed?
      root.xpath("contains(' feed RDF rss ', concat(' ', local-name(/*), ' '))")
    end

    def feed_attributes
      root.xpath("//link[@rel='alternate' and (#{types_query})]")
    end

    def types_query
      MIME_TYPES.map {|type| "@type='#{type}'" }.join(" or ")
    end

    def root
      if page.respond_to? :content_type and page.content_type =~ %r[^text/html]
        Nokogiri.HTML(page.body)
      else
        Nokogiri.XML(page.body)
      end
    end
  end
end

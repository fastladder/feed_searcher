class FeedSearcher
  class Page
    MIME_TYPES = {
      ".atom" => "application/atom+xml",
      ".rdf" => "application/rdf+xml",
      ".rss" => "application/rss+xml",
    }

    attr_reader :page

    def initialize(page)
      @page = page
    end

    def feed_urls
      urls = []
      urls << page.uri if feed_content_type? or is_feed?
      urls.concat feed_attributes.map {|attribute| attribute["href"] }
    end

    private

    def is_feed?
      root.xpath("contains(' feed RDF rss ', concat(' ', local-name(/*), ' '))")
    end

    def feed_content_type?
      content_type = page.response["content-type"]
      content_type.is_a? String and MIME_TYPES.has_value? content_type.gsub(/;.*$/, "")
    end

    def feed_extension?
      path = page.uri.path
      extension = File.extname(path)
      MIME_TYPES.has_key? extension
    end

    def feed_attributes
      root.xpath("//link[@rel='alternate' and (#{types_query})]")
    end

    def types_query
      MIME_TYPES.map {|_, type| "@type='#{type}'" }.join(" or ")
    end

    def root
      xml = nil
      body = page.body
      if body =~ /\A<\?xml\s/ or feed_content_type? or feed_extension?
        xml = Nokogiri.XML(body) do |config|
          config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOENT
        end rescue nil
      end
      xml or Nokogiri.HTML(body)
    end
  end
end

class FeedSearcher
  class Page
    EXTENSIONS = %w[
      atom
      rdf
      rss
    ]

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
      urls << url if (has_feed_mime_type? || has_feed_extension?) && xml?
      urls += links.map {|link| link["href"] }
    end

    private

    def has_xml_declaration?
      !!body.index("<?xml")
    end

    def has_feed_mime_type?
      MIME_TYPES.include?(mime_type)
    end

    def has_feed_extension?
      EXTENSIONS.include?(extension)
    end

    def parsable_as_xml?
      !!xml
    end

    def xml?
      has_xml_declaration? && parsable_as_xml?
    end

    def url
      page.uri.to_s
    end

    def content_type
      page.response["content-type"]
    end

    def mime_type
      content_type.sub(/;.*\z/, "") if content_type
    end

    def extension
      File.extname(page.uri.path).sub(/^\./, "")
    end

    def body
      page.body
    end

    def links
      root.xpath("//link[@rel='alternate' and (#{types_query})]")
    end

    def types_query
      MIME_TYPES.map {|type| "@type='#{type}'" }.join(" or ")
    end

    def root
      xml || html
    end

    def xml
      if @xml.nil?
        @xml = parse_xml
      else
        @xml
      end
    end

    def html
      Nokogiri.HTML(body)
    end

    def parse_xml
      Nokogiri.XML(body) do |config|
        config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOENT
      end
    rescue
      false
    end
  end
end

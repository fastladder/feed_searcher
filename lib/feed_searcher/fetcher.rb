class FeedSearcher
  class Fetcher
    def self.fetch(*args)
      new(*args).fetch
    end

    attr_reader :options, :url

    def initialize(url, options = {})
      @url     = url
      @options = options
    end

    def fetch
      FeedSearcher::Page.new(get)
    end

    private

    def get
      agent.get(url)
    end

    def agent
      Mechanize.new.tap do |mechanize|
        mechanize.open_timeout = options[:open_timeout] if options[:open_timeout]
        mechanize.read_timeout = options[:read_timeout] if options[:read_timeout]
        mechanize.user_agent   = options[:user_agent]   if options[:user_agent]
      end
    end
  end
end

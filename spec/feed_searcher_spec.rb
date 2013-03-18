require "spec_helper"

describe FeedSearcher do
  describe ".search" do
    before do
      stub_request(:get, "http://example.com/").to_return(
        :body => <<-EOF
          <!DOCTYPE HTML>
          <html>
            <head>
              <meta charset="UTF-8">
              <link href="http://example.com/1" rel="alternate" type="application/atom+xml" />
              <link href="http://example.com/2" rel="alternate" type="application/rdf+xml" />
              <link href="http://example.com/3" rel="alternate" type="application/rss+xml" />
              <link href="http://example.com/4" rel="alternate" type="application/xml" />
              <link href="http://example.com/5" rel="resource"  type="application/rss+xml" />
              <link href="http://www.example.com/6" rel="alternate"  type="application/rss+xml" />
              <link href="http://other-example.com/7" rel="alternate"  type="application/rss+xml" />
              <link href="/8" rel="alternate" type="application/rss+xml" />
            </head>
            <body>
              body
            </body>
          </html>
        EOF
      )
    end

    # This example makes sure the following specifications.
    #
    #   * it recognizes application/atom+xml
    #   * it recognizes application/rdf+xml
    #   * it recognizes application/rss+xml
    #   * it does not recognize application/xml
    #   * it keeps subdomain
    #   * it keeps other domain
    #   * it converts relative path to absolute url
    #
    it "returns feed URLs from given URL" do
      FeedSearcher.search("http://example.com/").should == %w[
        http://example.com/1
        http://example.com/2
        http://example.com/3
        http://www.example.com/6
        http://other-example.com/7
        http://example.com/8
      ]
    end

    it "returns itself if feed URL given" do
      url = "http://example.com/feed"
      stub_request(:get, url).to_return(
        :body => "hello",
        :headers => {
          "Content-Type" => "application/atom+xml; charset=utf-8"
        }
      )
      FeedSearcher.search(url).should == [url]
    end
  end
end

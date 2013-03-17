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
              <link href="http://example.com/rss.atom" rel="alternate" title="example" type="application/atom+xml" />
              <link href="http://rss.example.com/rss.atom" rel="alternate" title="example" type="application/atom+xml" />
              <link href="/rss.xml" rel="alternate" title="example" type="application/atom+xml" />
            </head>
            <body>
              example
            </body>
          </html>
        EOF
      )
    end

    it "returns feed URLs from given URL" do
      FeedSearcher.search("http://example.com/").should == %w[
        http://example.com/rss.atom
        http://rss.example.com/rss.atom
        http://example.com/rss.xml
      ]
    end
  end
end

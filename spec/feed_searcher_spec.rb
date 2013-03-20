require "spec_helper"
require "active_support/core_ext/string/strip"

describe FeedSearcher do
  describe ".search" do
    context "when the specified resource is HTML" do
      before do
        stub_request(:get, "http://example.com/").to_return(
          :body => <<-EOS.strip_heredoc
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
          EOS
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
      it "returns feed URLs from link elements in the specified resource" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/1
          http://example.com/2
          http://example.com/3
          http://www.example.com/6
          http://other-example.com/7
          http://example.com/8
        ]
      end
    end

    context "with feed MIME type and parsable XML and rss element" do
      before do
        stub_request(:get, "http://example.com/").to_return(
          :headers => { "Content-Type" => "application/rss+xml; charset=UTF-8" },
          :body    => <<-EOS.strip_heredoc
            <rss>
              <channel>
                <title>title</title>
                <link>http://exmple.com/</link>
                <item>
                  <title>item title</title>
                  <link>http://example.com/item</link>
                  <description>item description</description>
                </item>
              </channel>
            </rss>
          EOS
        )
      end

      it "returns itself as a feed url" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/
        ]
      end
    end

    context "with XML declaration and parsable XML and rss element" do
      before do
        stub_request(:get, "http://example.com/").to_return(
          :body    => <<-EOS.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <rss>
              <channel>
                <title>title</title>
                <link>http://exmple.com/</link>
                <item>
                  <title>item title</title>
                  <link>http://example.com/item</link>
                  <description>item description</description>
                </item>
              </channel>
            </rss>
          EOS
        )
      end

      it "returns itself as a feed url" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/
        ]
      end
    end

    context "with feed extension and parsable XML and feed element" do
      before do
        stub_request(:get, "http://example.com/feed.atom").to_return(
          :body => <<-EOS.strip_heredoc
            <feed xmlns="http://www.w3.org/2005/Atom">
              <title>title</title>
              <link rel="self" href="http://example.com/1"/>
              <link rel="alternate" href="http://example.com/"/>
              <entry>
                <title>item title</title>
                <link rel="alternate" href="http://example.com/"/>
                <content type="html">
                  <div xmlns="http://www.w3.org/1999/xhtml">
                    <p>item content</p>
                  </div>
                </content>
              </entry>
            </feed>
          EOS
        )
      end

      it "returns itself as a feed url" do
        FeedSearcher.search("http://example.com/feed.atom").should == %w[
          http://example.com/feed.atom
        ]
      end
    end
  end
end

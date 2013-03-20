require "spec_helper"
require "active_support/core_ext/string/strip"

describe FeedSearcher do
  describe ".search" do
    context "when there are link elements of feeds in the resource" do
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
      it "includes hrefs of them as feed URLs" do
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

    context "when the resource has feed MIME type and parsable XML and rss element" do
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

      it "includes the given URL as a feed URL" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/
        ]
      end
    end

    context "when the resource has XML declaration and parsable XML and rss element" do
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

      it "includes the given URL as a feed URL" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/
        ]
      end
    end

    context "when the resource has feed extension and parsable XML and feed element" do
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

      it "includes the given URL as a feed URL" do
        FeedSearcher.search("http://example.com/feed.atom").should == %w[
          http://example.com/feed.atom
        ]
      end
    end

    context "when the resource has XML declaration and parsable XML and no feed element" do
      before do
        stub_request(:get, "http://example.com/p3p.xml").to_return(
          :headers => { "Content-Type" => "application/xhtml+xml" },
          :body => <<-EOS.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <META xmlns="http://www.w3.org/2002/01/P3Pv1">
              <POLICY-REFERENCES>
              </POLICY-REFERENCES>
            </META>
          EOS
        )
      end

      it "does not includes the given URL as a feed URL" do
        FeedSearcher.search("http://example.com/p3p.xml").should == %w[
        ]
      end
    end

    context "when the parsable XML resource dosen't have feed MIME type and rss element" do
      before do
        stub_request(:get, "http://example.com/").to_return(
          :headers => { "Content-Type" => "application/xhtml+xml" },
          :body => <<-EOS.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <?xml-stylesheet href="/assets/application.css" type="text/css"?>
            <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
            <html xmlns="http://www.w3.org/1999/xhtml">
              <head>
                <link href="http://example.com/1" rel="alternate" type="application/atom+xml"/>
                <link href="http://example.com/2" rel="alternate" type="application/rdf+xml"/>
                <link href="http://example.com/3" rel="alternate" type="application/rss+xml"/>
                <title>title</title>
              </head>
              <body>
                <p>body</p>
              </body>
            </html>
          EOS
        )
      end

      it "includes hrefs of them as feed URLs" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/1
          http://example.com/2
          http://example.com/3
        ]
      end
    end
  end
end

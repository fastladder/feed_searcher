require "spec_helper"
require "active_support/core_ext/string/strip"

describe FeedSearcher do
  describe ".search" do
    it 'can subscribe to a feed of bokuyaba' do
      stub_request(:get, "https://championcross.jp/series/899dda204c3f2/rss").to_return(body: <<~EOS
        <rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:webfeeds="http://webfeeds.org/rss/1.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
        <channel>
          <title>僕の心のヤバイやつ【最新話無料】</title>
          <link>https://championcross.jp/series/899dda204c3f2</link>
          <atom:link rel="self" type="application/rss+xml" href="https://championcross.jp/series/899dda204c3f2/rss"/>
          <copyright>僕の心のヤバイやつ【最新話無料】</copyright>
          <webfeeds:icon>https://cdn-public.comici.jp/series/2/20240514165016604FC0B8E1EB60C6CC81C01AEC9EDC89401.png</webfeeds:icon>
          <webfeeds:logo>https://cdn-public.comici.jp/series/2/20240514165016604FC0B8E1EB60C6CC81C01AEC9EDC89401.png</webfeeds:logo>
          <webfeeds:accentColor>D80C24</webfeeds:accentColor>
          <webfeeds:related layout="card" target="browser"/>
          <webfeeds:analytics id="UA-114502607-1" engine="GoogleAnalytics"/>
          <language>ja</language>
          <pubDate>Tue, 09 Jul 2024 08:59:52 +0900</pubDate>
          <lastBuildDate>Tue, 09 Jul 2024 08:59:52 +0900</lastBuildDate>
        </channel>
        </rss>
      EOS
      )
      expect(FeedSearcher.search('https://championcross.jp/series/899dda204c3f2/rss').count).to eq 1
    end

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
        expect(FeedSearcher.search("http://example.com/")).to eq(%w[
          http://example.com/1
          http://example.com/2
          http://example.com/3
          http://www.example.com/6
          http://other-example.com/7
          http://example.com/8
        ])
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
        expect(FeedSearcher.search("http://example.com/")).to eq %w[
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
        expect(FeedSearcher.search("http://example.com/")).to eq %w[
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
        expect(FeedSearcher.search("http://example.com/feed.atom")).to eq %w[
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
        expect(FeedSearcher.search("http://example.com/p3p.xml")).to eq %w[
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
        expect(FeedSearcher.search("http://example.com/")).to eq %w[
          http://example.com/1
          http://example.com/2
          http://example.com/3
        ]
      end
    end
  end
end

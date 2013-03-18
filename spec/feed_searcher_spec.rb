require "spec_helper"

describe FeedSearcher do
  describe ".search" do
    before do
      stub_request(:get, "http://example.com/").to_return(
        :body => open(File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "example.html"))).read
      )

      stub_request(:get, "http://example.com/3").to_return(
        :content_type => 'application/rss+xml; charset=UTF-8',
        :body => open(File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "example.rss"))).read
      )

      stub_request(:get, "http://example.com/1").to_return(
        :content_type => 'text/plain',
        :body => open(File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "example.atom"))).read
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

    it "I'm the feed" do
      FeedSearcher.search("http://example.com/3").should == %w[
        http://example.com/3
      ]
    end

    it "Feed URL content type is text/plain" do
      FeedSearcher.search("http://example.com/1").should == %w[
        http://example.com/1
      ]
    end
  end
end

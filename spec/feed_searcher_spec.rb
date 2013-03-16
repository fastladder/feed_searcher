require "spec_helper"

describe FeedSearcher do
  describe ".search" do
    let(:body) do
      <<-EOF
        <!DOCTYPE HTML>
        <html>
          <head>
            <meta charset="UTF-8">
            <link href="http://example.com/rss.atom" rel="alternate" title="example" type="application/atom+xml" />
            <link href="http://example.com/rss.xml" rel="alternate" title="example" type="application/atom+xml" />
          </head>
          <body>
            example
          </body>
        </html>
      EOF
    end

    context "when response type is html" do
      before do
        stub_request(:get, "http://example.com/").to_return(
          :headers => { "Content-Type" => "text/html" },
          :body    => body
        )
      end

      it "returns feed URLs from given URL" do
        FeedSearcher.search("http://example.com/").should == %w[
          http://example.com/rss.atom
          http://example.com/rss.xml
        ]
      end
    end

    context "when response type is not html" do
      before do
        stub_request(:get, "http://example.com/").to_return(:body => body)
      end

      it "raises FeedSearher::InvalidResponseError" do
        expect { FeedSearcher.search("http://example.com/") }.
          to raise_error(FeedSearcher::InvalidResponseError)
      end
    end
  end
end

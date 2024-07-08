$LOAD_PATH.unshift File.expand_path("../../lib/feed_searcher", __FILE__)
require "feed_searcher"
require "webmock/rspec"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

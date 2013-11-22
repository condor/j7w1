require 'rspec'
require 'bundler/setup'

unless ENV['SKIP_COV']
  require 'simplecov'
  SimpleCov.start
end

require 'j7w1'

RSpec.configure do |config|
  # see https://github.com/rspec/rspec-core/blob/master/lib/rspec/core/configuration.rb for more infomation
end

require './twitter_search/error'
require './twitter_search/parser'
require './twitter_search/rest'
require './twitter_search/client'

client = TwitterSearch::Client.new
puts client.parse(ARGV).inspect
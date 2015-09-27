require 'optparse'

module TwitterSearch
  # This class contains code related to parsing command line arguments.
  class Parser
    class << self
      # This class parses the specified command line arguments and returns
      # formatted options.
      #
      # @param [Array] argv
      #   The arguments that were specified.
      #
      # @return [Hash]
      def parse(argv)
        options = {}

        parser = OptionParser.new 
        parser.banner = 'Usage: twitter_search.rb [options]'

        parser.on("--tweet QUERY", "Tweet to search for") do |query|
          options = {
            search_type: :tweet,
            q: query
          }
        end

        parser.on("--user QUERY", "User to search for") do |query|
          options = {
            search_type: :user,
            q: query
          }
        end

        parser.parse(argv)

        options
      end
    end
  end
end
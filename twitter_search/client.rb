module TwitterSearch
  # This class contains code for searching twitter.
  class Client
    # This method finds tweets matching the specified query.
    #
    # @param [String] q
    #   The query to use for searching.
    #
    # @param [Hash] options
    #   The options to pass along.
    #
    # @return [Array]
    def find_tweets(q, options = {})
      response = TwitterSearch::Rest.new(:get, '/1.1/search/tweets.json', options.merge(q: q)).request
      (response[:statuses] || []).map {|status| status[:text] }
    end

    # This method finds users matching the specified query.
    #
    # @param [String] q
    #   The query to use for searching.
    #
    # @param [Hash] options
    #   The options to pass along.
    #
    # @return [Array]
    def find_users(q, options = {})
      response = TwitterSearch::Rest.new(:get, '/1.1/users/search.json', options.merge(q: q)).request
      response.map {|user| user[:screen_name] }
    end

    # This method parses command line arguments and calls the correct method.
    #
    # @param [Array] argv
    #   The arguments that were specified.
    #
    # @return [Array]
    # @raise TwitterSearch::Error
    def parse(argv)
      options = TwitterSearch::Parser.parse(argv)
      case options[:search_type]
      when :tweet
        find_tweets(options[:q])
      when :user
        find_users(options[:q])
      else
        raise TwitterSearch::Error.new('Unknown option')
      end
    end
  end
end
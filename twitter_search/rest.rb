require 'simple_oauth'
require 'http'

module TwitterSearch
  # This class contains code related to API calls.
  class Rest
    BASE_URL = 'https://api.twitter.com'

    attr_accessor :request_method, :uri, :options

    # This method initializes a new rest object.
    #
    # @param [String] request_method
    #   The request method to use for this call.
    #
    # @param [String] path
    #   The path to call.
    #
    # @param [Hash] options
    #   Any options that were specified.
    #
    # @return [TwitterSearch::Rest]
    def initialize(request_method, path, options = {})
      @request_method = request_method
      @uri = BASE_URL + path
      @options = options
    end

    # This method makes the request and returns the response.
    #
    # @return [Hash]
    # @raise [TwitterSearch::Error]
    def request
      response = HTTP.with(request_headers).public_send(@request_method, @uri, params: @options)
      response_body = symbolize_keys!(response.parse)
      fail_or_return_response_body(response.code, response_body)
    end

  private

    def request_headers
      { authorization: oauth_auth_header.to_s }
    end

    def credentials
      {
        consumer_key:     ENV['TWITTER_SEARCH_CONSUMER_KEY'],
        consumer_secret:  ENV['TWITTER_SEARCH_CONSUMER_SECRET'],
        token:            ENV['TWITTER_SEARCH_TOKEN'],
        token_secret:     ENV['TWITTER_SEARCH_TOKEN_SECRET'],
      }
    end

    def oauth_auth_header
      SimpleOAuth::Header.new(@request_method, @uri, @options, credentials.merge(ignore_extra_keys: true))
    end

    def fail_or_return_response_body(code, body)
      error = error(code, body)
      fail(error) if error
      body
    end

    def error(code, body)
      if code != 200
        TwitterSearch::Error.new(body)
      end
    end

    def symbolize_keys!(object)
      if object.is_a?(Array)
        object.each_with_index do |val, index|
          object[index] = symbolize_keys!(val)
        end
      elsif object.is_a?(Hash)
        object.keys.each do |key|
          object[key.to_sym] = symbolize_keys!(object.delete(key))
        end
      end
      object
    end
  end
end
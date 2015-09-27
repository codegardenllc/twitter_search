require 'spec_helper'

describe TwitterSearch::Client do
  let(:response) { {} }
  let(:rest) { double }
  let(:client) { TwitterSearch::Client.new }

  before do
    allow(TwitterSearch::Rest).to receive(:new).and_return(rest)
    rest.stub request: response
  end

  describe "find_tweets" do
    let(:query) { double }
    let(:response) do
      {
        statuses: [
          { text: 'Tweet 1' },
          { text: 'Tweet 2' }
        ]
      }
    end

    subject { client.find_tweets(query) }

    before do
      subject
    end

    it "returns the tweets" do
      expect(subject).to eq ['Tweet 1', 'Tweet 2']
    end

    it "calls the api" do
      expect(TwitterSearch::Rest).to have_received(:new).with(
        :get, '/1.1/search/tweets.json', { q: query }
      )
    end
  end

  describe "find_users" do
    let(:query) { double }
    let(:response) do
      [
        { screen_name: 'user_1' },
        { screen_name: 'user_2' }
      ]
    end

    subject { client.find_users(query) }

    before do
      subject
    end

    it "returns the tweets" do
      expect(subject).to eq ['user_1', 'user_2']
    end

    it "calls the api" do
      expect(TwitterSearch::Rest).to have_received(:new).with(
        :get, '/1.1/users/search.json', { q: query }
      )
    end
  end

  describe "parse" do
    let(:tweets) { double }
    let(:users) { double }
    let(:options) { { q: 'query' } }
    let(:argv) { double }
    subject { client.parse(argv) }

    before do
      allow(TwitterSearch::Parser).to receive(:parse).and_return(options)
      client.stub find_tweets: tweets
      client.stub find_users: users
    end

    context "when search type is tweet" do
      before do
        options[:search_type] = :tweet
      end

      it "returns the tweets" do
        expect(subject).to eq tweets
      end
    end

    context "when search type is user" do
      before do
        options[:search_type] = :user
      end

      it "returns the users" do
        expect(subject).to eq users
      end
    end

    context "when search type is unknown" do
      before do
        options[:search_type] = :_blank
      end

      it "raises the error" do
        expect { subject }.to raise_error('Unknown option')
      end
    end
  end
end
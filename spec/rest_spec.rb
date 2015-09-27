require 'spec_helper'

describe TwitterSearch::Rest do
  let(:request_method) { :get }
  let(:path) { '/path/to/api' }
  let(:uri) { 'https://api.twitter.com' + path }
  let(:options) { { q: 'query' } }
  let(:rest_client) { TwitterSearch::Rest.new(request_method, path, options) }

  describe "request" do
    let(:request_headers) { double }
    let(:http) { double }
    let(:parsed_body) { {} }
    let(:code) { 200 }
    let(:response) { double(parse: parsed_body, code: code) }
    subject { rest_client.request }

    before do
      HTTP.stub with: http
      http.stub public_send: response
      rest_client.stub request_headers: request_headers
      rest_client.stub fail_or_return_response_body: parsed_body
      subject
    end

    it "returns the parsed body" do
      expect(subject).to eq parsed_body
    end

    it "calls http" do
      expect(HTTP).to have_received(:with).with(request_headers)
      expect(http).to have_received(:public_send).with(request_method, uri, params: options)
    end

    it "checks for errors" do
      expect(rest_client).to have_received(:fail_or_return_response_body).with(response.code, parsed_body)
    end
  end

  describe "request_headers" do
    subject { rest_client.send(:request_headers) }

    before do
      rest_client.stub oauth_auth_header: 'oauth header'
    end

    it "is a hash" do
      expect(subject).to be_a Hash
    end

    it "has the authorization key" do
      expect(subject[:authorization]).to eq 'oauth header'
    end
  end

  describe "credentials" do
    subject { rest_client.send(:credentials) }

    it "has all the keys" do
      expect(subject).to have_key(:consumer_key)
      expect(subject).to have_key(:consumer_secret)
      expect(subject).to have_key(:token)
      expect(subject).to have_key(:token_secret)
    end
  end

  describe "oauth_auth_header" do
    let(:credentials) { { u: 'p' } }
    let(:oauth_header) { double }
    subject { rest_client.send(:oauth_auth_header) }

    before do
      rest_client.stub credentials: credentials
      allow(SimpleOAuth::Header).to receive(:new).and_return(oauth_header)
      subject
    end

    it "calls oauth header" do
      expect(SimpleOAuth::Header).to have_received(:new).with(
        request_method, uri, options, credentials.merge({
          ignore_extra_keys: true
        })
      )
    end

    it "returns the oauth header" do
      expect(subject).to eq oauth_header
    end
  end

  describe "fail_or_return_response_body" do
    let(:code) { double }
    let(:body) { double }
    subject { rest_client.send(:fail_or_return_response_body, code, body) }

    before do
      rest_client.stub error: false
    end

    context "without any errors" do
      it "returns the body" do
        expect(subject).to eq body
      end
    end

    context "with an error" do
      before do
        rest_client.stub error: 'error'
      end

      it "fails" do
        expect { subject }.to raise_error('error')
      end
    end
  end

  describe "error" do
    let(:code) { 200 }
    let(:body) { 'body' }
    subject { rest_client.send(:error, code, body) }

    context "when code is 200" do
      it "returns false" do
        expect(subject).to be_falsey
      end
    end

    context "when code is something else" do
      let(:code) { 400 }

      it "returns an error" do
        expect(subject).to eq TwitterSearch::Error.new(body)
      end
    end
  end

  describe "symbolize_keys!" do
    let(:object) do
      [{'test1' => 'Value1'}, {'test2' => [{'test3' => 'Value3'}]}]
    end
    subject { rest_client.send(:symbolize_keys!, object) }

    context "when object is an array" do
      it "symbolizes all keys" do
        expect(subject).to eq([
          {test1: 'Value1'},
          {test2: [
            {test3: 'Value3'}
          ]}
        ])
      end
    end

    context "when object is a hash" do
      let(:object) do
        {'test1' => 'Value1', 'test2' => {'test3' => 'Value3'}}
      end

      it "symbolizes all keys" do
        expect(subject).to eq({
          test1: 'Value1',
          test2: {
            test3: 'Value3'
          }
        })
      end
    end
  end
end
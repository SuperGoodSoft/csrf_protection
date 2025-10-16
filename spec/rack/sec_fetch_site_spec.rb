# frozen_string_literal: true
 
RSpec.describe Rack::SecFetchSite do
  subject { described_class.new(app) }
  let(:app) { proc { |env| [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let(:get_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "GET", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }
  let(:post_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "POST", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }

  context "when the Sec-Fetch-Site contains cross-site" do
    let(:sec_fetch_site) { "cross-site" }

    it "raises an error for POST" do
      expect { subject.call(post_env) }.to raise_error(Rack::SecFetchSite::Error)
    end
    
    it "calls the app for GET" do
      expect(subject.call(get_env).first).to eq(200)
    end
  end

  context "when the Sec-Fetch-Site header contains same-origin" do
    let(:sec_fetch_site) { "same-origin" }

    it "calls the app for POST" do
      expect(subject.call(post_env).first).to eq(200)
    end
    
    it "calls the app for GET" do
      expect(subject.call(get_env).first).to eq(200)
    end
  end
end

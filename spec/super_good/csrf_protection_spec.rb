# frozen_string_literal: true

RSpec.describe SuperGood::CSRFProtection do
  subject { described_class.new(app) }
  let(:app) { proc { |env| [200, {"Content-Type" => "text/plain"}, ["OK"]] } }
  let(:get_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "GET", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }
  let(:head_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "HEAD", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }
  let(:options_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "OPTIONS", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }
  let(:post_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "POST", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }
  let(:put_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "PUT", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }
  let(:delete_env) { Rack::MockRequest.env_for("http://example.com:8080/", {:method => "DELETE", "HTTP_SEC_FETCH_SITE" => sec_fetch_site}) }

  context "when the Sec-Fetch-Site contains cross-site" do
    let(:sec_fetch_site) { "cross-site" }

    it "raises an error for POST" do
      expect { subject.call(post_env) }.to raise_error(SuperGood::CSRFProtection::Error)
    end

    it "raises an error for PUT" do
      expect { subject.call(put_env) }.to raise_error(SuperGood::CSRFProtection::Error)
    end

    it "raises an error for DELETE" do
      expect { subject.call(delete_env) }.to raise_error(SuperGood::CSRFProtection::Error)
    end

    it "calls the app for GET" do
      expect(subject.call(get_env).first).to eq(200)
    end

    it "calls the app for HEAD" do
      expect(subject.call(head_env).first).to eq(200)
    end

    it "calls the app for OPTIONS" do
      expect(subject.call(options_env).first).to eq(200)
    end
  end

  context "when the Sec-Fetch-Site header contains same-origin" do
    let(:sec_fetch_site) { "same-origin" }

    it "calls the app for POST" do
      expect(subject.call(post_env).first).to eq(200)
    end

    it "calls the app for PUT" do
      expect(subject.call(put_env).first).to eq(200)
    end

    it "calls the app for DELETE" do
      expect(subject.call(delete_env).first).to eq(200)
    end

    it "calls the app for GET" do
      expect(subject.call(get_env).first).to eq(200)
    end

    it "calls the app for HEAD" do
      expect(subject.call(head_env).first).to eq(200)
    end

    it "calls the app for OPTIONS" do
      expect(subject.call(options_env).first).to eq(200)
    end
  end
end

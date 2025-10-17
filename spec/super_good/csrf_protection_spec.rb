# frozen_string_literal: true

RSpec.describe SuperGood::CSRFProtection do
  subject {
    described_class.new(app, raise_error: raise_error_option).call(env)
  }

  let(:app) { ->(_env) { [200, {"Content-Type" => "text/plain"}, ["OK"]] } }
  let(:env) {
    Rack::MockRequest.env_for("http://example.com:8080/", {
      :method => method,
      "HTTP_SEC_FETCH_SITE" => sec_fetch_site
    })
  }

  shared_examples "allows request" do |method|
    context method do
      let(:method) { method }
      let(:raise_error_option) { true }

      it "allows the request" do
        expect(subject.first).to eq(200)
      end
    end
  end

  shared_examples "denies request" do |method|
    context method do
      let(:method) { method }

      context "when raise_error is true" do
        let(:raise_error_option) { true }

        it "raises an error" do
          expect { subject }.to raise_error(SuperGood::CSRFProtection::Error)
        end
      end

      context "when raise_error is false" do
        let(:raise_error_option) { false }

        it "returns a 403 response" do
          expect(subject)
            .to eq([403, {"Content-Type" => "text/plain"}, ["Forbidden"]])
        end
      end
    end
  end

  context "when the Sec-Fetch-Site contains cross-site" do
    let(:sec_fetch_site) { "cross-site" }

    include_examples "allows request", "GET"
    include_examples "allows request", "HEAD"
    include_examples "allows request", "OPTIONS"
    include_examples "denies request", "POST"
    include_examples "denies request", "PUT"
    include_examples "denies request", "DELETE"
  end

  context "when the Sec-Fetch-Site header contains same-origin" do
    let(:sec_fetch_site) { "same-origin" }

    include_examples "allows request", "GET"
    include_examples "allows request", "HEAD"
    include_examples "allows request", "OPTIONS"
    include_examples "allows request", "POST"
    include_examples "allows request", "PUT"
    include_examples "allows request", "DELETE"
  end

  context "when raise_error is false" do
    let(:raise_error_option) { false }

    context "when the Sec-Fetch-Site contains cross-site" do
      let(:sec_fetch_site) { "cross-site" }

      include_examples "allows request", "GET"
      include_examples "allows request", "HEAD"
      include_examples "allows request", "OPTIONS"
      include_examples "denies request", "POST"
      include_examples "denies request", "PUT"
      include_examples "denies request", "DELETE"
    end

    context "when the Sec-Fetch-Site header contains same-origin" do
      let(:sec_fetch_site) { "same-origin" }

      include_examples "allows request", "GET"
      include_examples "allows request", "HEAD"
      include_examples "allows request", "OPTIONS"
      include_examples "allows request", "POST"
      include_examples "allows request", "PUT"
      include_examples "allows request", "DELETE"
    end
  end
end

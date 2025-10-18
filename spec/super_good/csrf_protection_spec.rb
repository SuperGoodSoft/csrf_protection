# frozen_string_literal: true

RSpec.describe SuperGood::CSRFProtection do
  subject {
    described_class.new(app, raise_error: raise_error_option).call(env)
  }

  let(:app) { ->(_env) { [200, {"Content-Type" => "text/plain"}, ["OK"]] } }
  let(:env) {
    Rack::MockRequest.env_for("http://example.com:8080/", {
      :method => method,
      "HTTP_SEC_FETCH_SITE" => sec_fetch_site,
      "HTTP_ORIGIN" => origin,
      "HTTP_HOST" => host
    })
  }
  let(:sec_fetch_site) { nil }
  let(:origin) { nil }
  let(:host) { nil }

  shared_examples "allows safe HTTP methods" do
    %w[GET HEAD OPTIONS].each do |http_method|
      context http_method do
        let(:method) { http_method }
        let(:raise_error_option) { true }

        it "allows the request" do
          expect(subject.first).to eq(200)
        end
      end
    end
  end

  shared_examples "allows unsafe HTTP methods" do
    %w[POST PUT PATCH DELETE].each do |http_method|
      context http_method do
        let(:method) { http_method }
        let(:raise_error_option) { true }

        it "allows the request" do
          expect(subject.first).to eq(200)
        end
      end
    end
  end

  shared_examples "denies unsafe HTTP methods" do
    %w[POST PUT PATCH DELETE].each do |http_method|
      context http_method do
        let(:method) { http_method }

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
  end

  context "when the Sec-Fetch-Site contains cross-site" do
    let(:sec_fetch_site) { "cross-site" }

    include_examples "allows safe HTTP methods"
    include_examples "denies unsafe HTTP methods"
  end

  context "when the Sec-Fetch-Site header contains same-origin" do
    let(:sec_fetch_site) { "same-origin" }

    include_examples "allows safe HTTP methods"
    include_examples "allows unsafe HTTP methods"
  end

  context "when the Sec-Fetch-Site header is missing" do
    let(:sec_fetch_site) { nil }

    context "when the Origin header is present" do
      let(:origin) { "http://example.com:8080" }

      context "when it matches the Host header" do
        let(:host) { "example.com:8080" }

        include_examples "allows safe HTTP methods"
        include_examples "allows unsafe HTTP methods"
      end

      context "when it doesn't match the Host header" do
        let(:host) { "differentdomain.com:8080" }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end

      context "when the Host header isn't present" do
        let(:host) { nil }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end

      context "when the Origin has no port" do
        let(:origin) { "http://example.com" }
        let(:host) { "example.com" }

        include_examples "allows unsafe HTTP methods"
      end

      context "when Origin differs only by port" do
        let(:origin) { "http://example.com:8080" }
        let(:host) { "example.com:9000" }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end

      context "when the Origin differs only by domain" do
        let(:host) { "sub.example.com:8080" }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end

      context 'when the Origin header is "null"' do
        let(:origin) { "null" }
        let(:host) { "example.com:8080" }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end

      context "when the Origin header is malformed" do
        let(:origin) { "http://////:////" }
        let(:host) { "example.com:8080" }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end

      context "when the Host header is malformed" do
        let(:host) { "::::::" }

        include_examples "allows safe HTTP methods"
        include_examples "denies unsafe HTTP methods"
      end
    end

    context "when the Origin header is missing" do
      let(:origin) { nil }
      let(:host) { "example.com:8080" }

      include_examples "allows safe HTTP methods"
      include_examples "allows unsafe HTTP methods"
    end
  end
end

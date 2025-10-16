# frozen_string_literal: true

require_relative "csrf_protection/version"

module SuperGood
  class CSRFProtection
    class Error < StandardError; end

    def initialize(app)
      @app = app
    end

    def call(env)
      if unsafe_request?(env) && env["HTTP_SEC_FETCH_SITE"] != "same-origin"
        raise(Error, "Invalid Sec-Fetch-Site header")
      end

      @app.call(env)
    end

    private

    SAFE_METHODS = ["GET", "HEAD", "OPTIONS"].freeze

    def unsafe_request?(env)
      !SAFE_METHODS.include?(env["REQUEST_METHOD"])
    end
  end
end

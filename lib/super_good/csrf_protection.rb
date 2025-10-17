# frozen_string_literal: true

require_relative "csrf_protection/version"

module SuperGood
  class CSRFProtection
    SAFE_METHODS = ["GET", "HEAD", "OPTIONS"].freeze

    class Error < StandardError; end

    def initialize(app, raise_error: false)
      @app = app
      @raise_error = raise_error
    end

    def call(env)
      return @app.call(env) unless unsafe_request?(env) && env["HTTP_SEC_FETCH_SITE"] != "same-origin"

      if @raise_error
        raise(Error, "Invalid Sec-Fetch-Site header")
      else
        [403, {"Content-Type" => "text/plain"}, ["Forbidden"]]
      end
    end

    private

    def unsafe_request?(env)
      !SAFE_METHODS.include?(env["REQUEST_METHOD"])
    end
  end
end

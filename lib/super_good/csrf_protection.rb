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

    def unsafe_request?(env)
      env["REQUEST_METHOD"] != "GET"
    end
  end
end

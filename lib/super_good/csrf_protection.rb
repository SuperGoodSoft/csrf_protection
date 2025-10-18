# frozen_string_literal: true

require_relative "csrf_protection/version"

module SuperGood
  class CSRFProtection
    class Error < StandardError; end

    SAFE_METHODS = %w[GET HEAD OPTIONS].freeze
    SAFE_SEC_FETCH_SITE_VALUES = %w[same-origin none].freeze

    def initialize(app, raise_error: false)
      @app = app
      @raise_error = raise_error
    end

    def call(env)
      return @app.call(env) unless unsafe_request?(env) && cross_origin?(env)

      if @raise_error
        raise(Error, "Cross-origin request denied")
      else
        [403, {"Content-Type" => "text/plain"}, ["Forbidden"]]
      end
    end

    private

    def unsafe_request?(env)
      !SAFE_METHODS.include?(env["REQUEST_METHOD"])
    end

    def cross_origin?(env)
      sec_fetch_site = env["HTTP_SEC_FETCH_SITE"]
      return !SAFE_SEC_FETCH_SITE_VALUES.include?(sec_fetch_site) if sec_fetch_site

      origin = env["HTTP_ORIGIN"]
      return false unless origin

      host = env["HTTP_HOST"] || env["SERVER_NAME"]
      origin_host = extract_host_from_origin(origin)

      origin_host != host
    end

    def extract_host_from_origin(origin)
      uri = URI.parse(origin)
      (uri.port == uri.default_port) ? uri.host : "#{uri.host}:#{uri.port}"
    rescue URI::InvalidURIError
      nil
    end
  end
end

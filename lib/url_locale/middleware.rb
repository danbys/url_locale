module UrlLocale
  class Middleware
    # Returns an <tt>I18n.available_locales - I18n.default_locale</tt>
    def self.translations
      @@translations ||= (I18n.available_locales - [I18n.default_locale]).map &:to_s
    end

    # Returns a Regexp to extract the locale from +request.host+
    def self.subdomain_locales
      @@subdomain_locales ||= Regexp.new "(^|\.)(#{translations*'|'})\."
    end

    # Returns a Regexp to extract the locale from +request.path+
    def self.path_locales
      @@subdomain_locales ||= Regexp.new "^\/(#{translations*'|'})\/"
    end

    def initialize app
      @app = app
    end

    def call env
      status, headers, body = @app.call env
      request = ::Rack::Request.new env
      if request.path !~ /^\/(javascripts|stylesheets|images)/
        locale = if UriLocale.translations.present?
          UriLocale.subdomain_locales.match(request.host).try(:[], 2) ||
          UriLocale.path_locales.match(request.path).try(:[], 1) ||
          I18n.default_locale.to_s
        end
        env['rack.locale'] = headers['Content-Language'] = I18n.locale = locale 
      end
      [status, headers, body]
    end
  end
end
require "url_locale/middleware"
module UrlLocale  
  
  class << self
    # Returns an <tt>I18n.available_locales - I18n.default_locale</tt>
    def translations
      @@translations ||= (I18n.available_locales - [I18n.default_locale]).map &:to_s
    end

    # Returns a Regexp to extract the locale from +request.host+
    def subdomain_locales
      @@subdomain_locales ||= Regexp.new "(^|\.)(#{translations*'|'})\."
    end

    # Returns a Regexp to extract the locale from +request.path+
    def path_locales
      @@path_locales ||= Regexp.new "^\/(#{translations*'|'})(\/|$)"
    end
    
    def host_mode
      @@mode = :host
    end
    
    def mode
      @@mode ||= :path
    end
    
    def detect request
      if translations.present?
        if mode == :path
          path_locales.match(request.path).try :[], 1          
        else
          subdomain_locales.match(request.host).try :[], 2
        end
      end || I18n.default_locale.to_s
    end
  end
end

require "url_locale/middleware"
module UrlLocale  
  
  class << self
    # Returns an <tt>I18n.available_locales - I18n.default_locale</tt>
    def translations
      @@translations ||= (I18n.available_locales - [I18n.default_locale]).map &:to_s
    end

    # Returns a Regexp to extract the locale from +request.host+
    # def subdomain_locales
    #   @@subdomain_locales ||= Regexp.new "(^|\.)(#{translations*'|'})\."
    # end

    # Returns a Regexp to extract the locale from +request.path+
    def path_locales
      @@path_locales ||= Regexp.new "^\/(#{translations*'|'})(\/|$)"
    end
    
    # def host_mode
    #   @@mode = :host
    # end
    # 
    # def mode
    #   @@mode ||= :path
    # end
    
    def host_locales
      @@host_locales ||= begin
        config_fpath = File.join Rails.root, 'config', 'url_locale.yml'
        result = {}
        if File.exist? config_fpath
          YAML::load_file(config_fpath).each do |locale, hosts|
            for host in hosts
              result[host] = locale.underscore
            end
          end
        end
        result
      end
    end
    
    def detect request
      if translations.present?
        host_url = request.url.split(request.host_with_port).first + request.host_with_port
        host_locales[host_url] ||
          path_locales.match(request.path).try(:[], 1) || 
          I18n.default_locale.to_s
      end
    end
  end
end

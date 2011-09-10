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
    
    def formats
      @@formats ||= sources.values.map{ |h| h[:format]}.uniq
    end
    
    def sources
      @@sources ||= begin
        config_fpath = File.join Rails.root, 'config', 'url_locale.yml'
        result = {}
        if File.exist? config_fpath
          YAML::load_file(config_fpath).each do |locale, tmp|
            if tmp.is_a?(Array)
              tmp.each_with_index do |source, i|
                result[source] = { locale: locale, index: i, format: 'screen' }
              end
            else
              tmp.each do |format, sources|
                sources.each_with_index do |source, i|
                  result[source] = { locale: locale, index: i, format: format }
                end
              end
            end
          end
        end
        result
      end
    end
    
    def locale url
      sources[source(url)].try(:[], :locale) ||
        path_locales.match(uri(url).path).try(:[], 1) ||
        I18n.default_locale.to_s
    end
    
    def uri url
      url.is_a?(URI) ? url : URI.parse(url)
    end
    
    def format url
      sources[source(url)].try :[], :format
    end
    
    # locale(url)
    # format(url)
    # source(url, :handheld)
    # source(url, :en, :handheld)
    def source *args
      first = args.shift
      if args.blank? and first.is_a?(String) 
        # uri(first).to_s
        url = uri first
        "#{url.host}#{':'+url.port.to_s unless url.port == 80}"
      elsif first.is_a? Hash
        sources.each do |source, options|
          return source if options == first
        end
      else
        if first.is_a? String
          url = source first
        # elsif args.size != 3
        #   raise ArgumentError, "Invalid agruments: url or [:locale, :format, :index] is required"
        end
        args = args.index_by do |arg|
          if arg.is_a? Fixnum
            :index
          elsif I18n.available_locales.include? arg.to_sym
            :locale
          elsif formats.include? arg.to_s
            :format
          else
            raise ArgumentError, "Invalid argument '#{arg}' in #{([first]+args).inspect}"
          end
        end
        args[:locale] ||= I18n.locale
        args[:locale] = args[:locale].to_s
        args[:format] ||= format(url) || :screen
        args[:format] = args[:format].to_s
        args[:index] ||= sources[url][:index]
        
        # raise args.inspect
        source args
        #raise ArgumentError, "Arguments is not found in config file or config file is corrupt"
      end
    end
  end
end

# url_locale

Add _content-language_ to the response header using Rack. The locale variable is parsed from request URL, if no locale can be detected then `I18n.default_locale` will be your fallback.

## Rack

Rack middleware parses the URL and sets the response header _content-language_ attribute accordingly. Since the header is passed on to the web server, inserting `<meta http-equiv="Content-Language" content="en"/>` in the response body is superfluous. Please note that cached responses passing through Rack also will get the correct content-language header (can be tricky to configure the web server to do this).

## Detect URL locale

The gem will look for `I18n.available_locales` in `request.host` or `request.path`. In Path mode which is the default mode, `locale` will be parsed from the path. In Host mode `locale` will be parsed from the host string.

### Path mode examples
    
    I18n.default_locale => :en
    I18n.available_locales => [:sv, :pt]
    
    http://example.com                        => "en"
    http://sv.example.com                     => "en"
    http://www.example.com/about              => "en"
    http://www.example.com/pt/em              => "pt"
    http://example.com/sv/om                  => "sv"
    http://example.com/fr/sur                 => "en" # fallback

If a locale can't be detected, fallback will be `I18n.default_locale`

### Host mode examples

    I18n.default_locale => :en
    I18n.available_locales => [:sv, :pt]
    
    http://example.com                        => "en"
    http://sv.example.com                     => "sv"
    http://www.example.com/pt/em              => "en"
    http://fr.example.com/sur                 => "en" # fallback
    http://example.com/sv/sur                 => "en"
    http://sv.example.com/pt/em               => "sv" 
    http://sv.mobile.example.com             => "sv"
    http://modile.sv.example.com             => "en" # fallback

If a locale can't be detected, fallback will be `I18n.default_locale`

## Installation and configuration

1. Run `rake middleware RAILS_ENV=development` and `rake middleware RAILS_ENV=production`
2. Notice the order of the middleware for each environment
3. Add `gem 'url_locale'` to Gemfile
4. Insert `UrlLocale::Middleware` as the first middleware in the Rack middleware stack
5. (optional) Configure - Change to Host mode
6. Add before filter in application to set locale

### Rails 3.1 example

    $ rake middleware RAILS_ENV=development
    use ActionDispatch::Static
    use Rack::Lock
    use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x101fefef0>
    use Rack::Runtime
    use Rack::MethodOverride
    use Rails::Rack::Logger
    use ActionDispatch::ShowExceptions
    use ActionDispatch::RemoteIp
    use Rack::Sendfile
    use ActionDispatch::Reloader
    use ActionDispatch::Callbacks
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    use ActiveRecord::QueryCache
    use ActionDispatch::Cookies
    use ActionDispatch::Session::CookieStore
    use ActionDispatch::Flash
    use ActionDispatch::ParamsParser
    use ActionDispatch::Head
    use Rack::ConditionalGet
    use Rack::ETag
    use ActionDispatch::BestStandardsSupport
    run Learning::Application.routes
    
    $ rake middleware RAILS_ENV=production
    use Rack::Cache
    use Rack::Lock
    use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x101feeb68>
    use Rack::Runtime
    use Rack::MethodOverride
    use Rails::Rack::Logger
    use ActionDispatch::ShowExceptions
    use ActionDispatch::RemoteIp
    use Rack::Sendfile
    use ActionDispatch::Callbacks
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    use ActiveRecord::QueryCache
    use ActionDispatch::Cookies
    use ActionDispatch::Session::CookieStore
    use ActionDispatch::Flash
    use ActionDispatch::ParamsParser
    use ActionDispatch::Head
    use Rack::ConditionalGet
    use Rack::ETag
    use ActionDispatch::BestStandardsSupport
    run Learning::Application.routes
    

    # Gemfile
    gem 'url_locale'
    
    # config/environments/development.rb
    config.middleware.insert_before "ActionDispatch::Static", UrlLocale::Middleware
    
    # config/environments/production.rb
    config.middleware.insert_before "Rack::Cache", UrlLocale::Middleware
    
    # config/initializers/url_locale.rb (optional configuration file)
    UrlLocale.host_mode # comment out this line to run Path mode
    
    # app/controllers/application_controller.rb
    before_filter :set_locale

    def set_locale
      I18n.locale = UrlLocale.detect request
    end

## Development

There is room for improvement for this gem

- Easier installation
- Improved parsing modes
- Other ideas?

If url_locale gets more then 1000 downloads, further development might be worth the effort :)

## Copyright

Copyright (c) 2011 Dan Byström. See LICENSE.txt for
further details.


# url_locale

Add _content-language_ to the response header using Rack. The locale variable is parsed from request URL, if no locale can be detected then `I18n.default_locale` will be your fallback.

## Rack

Rack middleware parses the URL and sets the response header _content-language_ attribute accordingly. Since the header is passed on to the web server, inserting `<meta http-equiv="Content-Language" content="en"/>` in the response body is superfluous. Please note that cached responses passing through Rack also will get the correct content-language header (can be tricky to configure the web server to do this).

## Detect URL locale

The gem will parse `request.url` for `I18n.available_locales` in the following order:

1. `request.url` listed in `config/url_locale.yml`?
2. `request.path` starts with `I18n.available_locales`
3. `I18n.default_locale`


## Example

```yaml
# config/url_locale.yml
en:
  - http://localehost:3000
  - http://example.com
sv:
  - http://localehost:3001
  - http://example.se
```
```
I18n.default_locale => :en
I18n.available_locales => [:en, :sv]

http://example.com                        => "en"
http://sv.example.com                     => "en" # fallback
http://example.se/about                   => "sv"
http://example.com/sv/om                  => "en"
http://www.example.com/sv/om              => "sv" # parse path

http://localhost:3000                     => "en"
http://sv.localhost:3000                  => "en" # fallback
http://localhost:3001/about               => "sv"
http://localhost:3000/sv/om               => "en"
http://localhost:3002/sv/om              => "sv" # parse path
```

If a locale can't be detected, fallback will be `I18n.default_locale`

## Installation and configuration

1. Run `rake middleware RAILS_ENV=development` and `rake middleware RAILS_ENV=production`
2. Notice the order of the middleware for each environment
3. Add `gem 'url_locale'` to Gemfile
4. Insert `UrlLocale::Middleware` as the first middleware in the Rack middleware stack
5. (optional) create `config/url_locale`
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
    
    # config/url_locale.yml (optional configuration file)
    en:
      - http://localehost:3000
      - http://example.com
    sv:
      - http://localehost:3001
      - http://example.se
    
    # app/controllers/application_controller.rb
    before_filter :set_locale

    def set_locale
      I18n.locale = UrlLocale.detect request
    end

## Development

There is room for improvement for this gem

- Easier installation
- Other ideas?

If url_locale gets more then 1000 downloads, further development might be worth the effort :)

## Copyright

Copyright (c) 2011 Dan Byström. See LICENSE.txt for
further details.


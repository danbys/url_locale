require "rails"
module UrlLocale
  class Engine < Rails::Engine
    initializer 'url_locale' do |app|
      #app.middleware.insert_before ActionDispatch::Static, RequestUnescape
      app.middleware.insert_before ActionDispatch::Static, Middleware
    end
  end
end

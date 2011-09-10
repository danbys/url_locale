module UrlLocale
  class Middleware

    def initialize app
      @app = app
    end

    def call env
      status, headers, body = @app.call env
      request = ::Rack::Request.new env
#      mime_types = env["action_dispatch.request.formats"] || []
#      if mime_types.find{ |mt| UrlLocale.formats.include? mt.sub_type }
        env['rack.locale'] = headers['Content-Language'] = UrlLocale.locale(request.url)
#      end
      [status, headers, body]
    end
  end
end
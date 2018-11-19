Rack::Timeout::Logger.level = Logger::ERROR

service_timeout = Rails.env.development? ? 90 : 28
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, :service_timeout => service_timeout

require 'sidekiq'
require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["youruser", "yourpassword"]
end

Sidekiq.configure_server do |config|
  size = Sidekiq.options[:concurrency]
  
  ActiveRecord::Base.connection_pool.disconnect!
  # now updating activerecord settings
  config = Rails.application.config.database_configuration[Rails.env]
  config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
  config['pool']              = ENV['DB_POOL']      || size
  ActiveRecord::Base.establish_connection(config)
end
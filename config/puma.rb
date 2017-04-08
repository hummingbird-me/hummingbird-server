workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 8)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

before_fork do
  PumaWorkerKiller.config do |config|
    config.ram           = 1024  # mb
    config.frequency     = 60    # seconds
    config.percent_usage = 0.94
    config.rolling_restart_frequency = 24 * 3600 # 12 hours in seconds
  end
  PumaWorkerKiller.start
end

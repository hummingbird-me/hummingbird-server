git_source(:github) { |repo| "https://github.com/#{repo}.git" }
source 'https://rubygems.org'

# Core Stuff
gem 'puma'
gem 'rails', '5.2.4.4'

# Database Stuff
gem 'activerecord-import' # Run bulk imports quicker
gem 'algoliasearch-rails' # Future Search
gem 'attr_encrypted', '~>3.1.0' # encrypt linked_profile tokens
gem 'chewy' # ElasticSearch (TODO: remove this once we switch to Algolia)
gem 'connection_pool' # Pool our Redises
gem 'hiredis' # Faster redis
gem 'mongo' # MongoDB for Aozora
gem 'pg' # Postgres
gem 'redis', '> 3.3.0', require: ['redis', 'redis/connection/hiredis'] # Redis
gem 'redis-rails' # Redis on Rails

# Auth{entication,orization}
gem 'bcrypt'
gem 'doorkeeper'
gem 'doorkeeper-grants_assertion', git: 'https://github.com/doorkeeper-gem/doorkeeper-grants_assertion'
gem 'jwt' # Used for Nolt SSO
gem 'pundit'
gem 'pundit-resources', github: 'hummingbird-me/pundit-resources'
gem 'rolify'

# Attachments
gem 'apollo_upload_server'
gem 'aws-sdk-s3', '~> 1'
# released version of blurhash has too-narrow ffi version
gem 'blurhash', github: 'gargron/blurhash'
gem 'delayed_paperclip'
gem 'image_optim', require: false
gem 'image_optim_pack', require: false
gem 'image_processing'
gem 'marcel'
gem 'mini_magick'
gem 'paperclip', '~> 6.0.0'
gem 'paperclip-meta'
gem 'paperclip-optimizer'
gem 'shrine', '>= 3.3.0'

# Background tasks
gem 'sidekiq', '~> 5'
gem 'sidekiq-debounce'
gem 'sidekiq-scheduler'

# Text pipeline
gem 'html-pipeline'
gem 'kramdown'
gem 'kramdown-parser-gfm'
gem 'rinku'
gem 'sanitize'

# Feature Flagging
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'

# API Frameworks
gem 'graphql'
gem 'graphql-batch'
gem 'jsonapi-resources', '0.9.0'

# Miscellaneous Utilities
gem 'active_flag' # Bitfields!
gem 'addressable' , '>= 2.8.0' # Fancy address logic
gem 'bootsnap' # Faster boots
gem 'counter_culture' # Fancier counter caches
gem 'faraday'
gem 'faraday_middleware'
gem 'fastimage' # Quickly get image sizes
gem 'friendly_id' # slug-urls-are-cool
gem 'google-api-client' , '>= 0.53.0' # Google APIs
gem 'graphql-client' # make graphql calls
gem 'health_bit' # Allow Kubernetes to check the health
gem 'http' , '>= 4.4.1' # Pewpew HTTP calls easier
gem 'ice_cube' # Episode release schedules
gem 'lograge' # Non-shitty logging
gem 'mechanize' , '>= 2.8.1' # Automating interaction with websites
gem 'nokogiri', '~> 1.11.0' # Parse MAL XML shit
gem 'one_signal' # Send push notifications
gem 'paranoia', '~> 2.4' # Faux deletion
gem 'postmark-rails' # Send via Postmark
gem 'ranked-model' # Sortables!
gem 'retriable' # Retry when errors happen
gem 'roadie-rails' , '>= 2.2.0' # Inline CSS for emails
gem 'ruby-progressbar' # Fancy progress bars for Rake tasks
gem 'sass-rails' # Process SCSS for emails
gem 'sitemap_generator' # Generate Sitemaps
gem 'strait' # Rate limiting anything!
gem 'stream-ruby', '~> 2.10.0' # Feeds
gem 'stream_rails', github: 'GetStream/stream-rails',
                    branch: 'feature/subreference-enrichment' # Feed Enrichment
gem 'typhoeus' # Parallelize scraping tasks

# Cash Money
gem 'stripe'

# Rack Middleware
gem 'rack-attack'
gem 'rack-cors'

# Optimizations
gem 'fast_blank' # Faster String#blank?
gem 'oj' # Blazing-fast JSON parsing
gem 'oj_mimic_json' # Hook it in place of JSON gem
gem 'parallel' # Process shit in parallel

gem 'sentry-raven' # Send error data to Sentry

# Admin Panel
gem 'pg_query' # pghero indexes
gem 'pghero'
gem 'rails_admin'
gem 'sinatra' # used by sidekiq/web

group :development, :test do
  gem 'dotenv-rails' # Load default ENV
  gem 'pry-rails' # Better Console
  gem 'spring' # Faster CLI

  # Rubocop stuff
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Development+Testing
  gem 'database_cleaner' # Clean the database fully before doing anything
  gem 'factory_bot_rails' # Factories > Fixtures
  gem 'rspec-rails' # Specs > Tests

  # Guard notices filesystem changes and *does things*
  gem 'guard'
  gem 'guard-rspec', require: false # Running specs

  # Useful for benchmarking!
  gem 'benchmark-ips'
  gem 'derailed_benchmarks'

  # Debugging tests and scripts
  gem 'pry-byebug'
end

group :test do
  gem 'faker' # Fake data
  gem 'json_expressions' # Test outputted JSON
  gem 'rspec-sidekiq' # Test Sidekiq jobs
  gem 'shoulda-matchers' # it { should(:have_shoulda) }
  gem 'stripe-ruby-mock', require: 'stripe_mock' # Mock Stripe API
  gem 'timecop' # stop [hammer-]time
  gem 'webmock' , '>= 3.12.2' # Web faking

  # Coverage
  gem 'simplecov' # Local coverage

  # Libraries used to test our API itself
  gem 'oauth2', github: 'oauth-xx/oauth2', branch: 'master'
end

group :production, :staging do
  gem 'librato-rails' # Metrics
  gem 'puma_worker_killer'
  gem 'rails_12factor' # Log to stdout, serve assets
end

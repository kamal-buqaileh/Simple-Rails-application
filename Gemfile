source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "activerecord-postgis-adapter", "~> 11.0"
gem "rgeo", "~> 3.0"
gem "rgeo-activerecord", "~> 8.0"
gem "jsonapi-serializer"
gem "redis"

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false

gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers", "~> 5.0"
end

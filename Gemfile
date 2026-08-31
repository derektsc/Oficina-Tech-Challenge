source "https://rubygems.org"

ruby "3.3.6"

gem "rails", "~> 8.0.0"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "bcrypt", "~> 3.1.7"
gem "jwt"
gem "rack-cors"
gem "bootsnap", require: false
gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "simplecov", require: false
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end

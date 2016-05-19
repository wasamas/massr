source 'https://rubygems.org'

ruby '~> 2.4.1'

gem 'sinatra', require: 'sinatra/base'

gem 'puma'
gem 'hamlit', require: 'hamlit'
gem 'omniauth', require: 'omniauth'
gem 'omniauth-twitter', require: 'omniauth-twitter'
gem 'mongoid', require: 'mongoid'
gem 'bson_ext'
gem 'rack_csrf', require: 'rack/csrf'
gem 'rack-ssl', require: 'rack/ssl'
gem 'mail', require: 'mail'
gem 'signet'
gem 'picasa'
gem 'twitter'
gem 'gyazo'
gem 'rmagick'
gem 'dalli', require: ['dalli', 'rack/session/dalli']
gem 'celluloid'
gem 'memcachier', require: 'memcachier'

group :development, :test do
	gem 'rake'
	gem 'guard-rspec'
	gem 'fuubar'
	gem 'sinatra-contrib', require: 'sinatra/reloader'
	gem 'dotenv', require: 'dotenv'
	gem 'pry'
	gem 'therubyracer'
end

group :production do
	gem 'newrelic_rpm'
end

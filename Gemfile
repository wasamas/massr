source 'https://rubygems.org'

ruby '~> 2.4.1'

gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-asset-pipeline', require: 'sinatra/asset_pipeline'
gem 'sprockets-helpers'
gem 'uglifier'
gem 'yui-compressor'

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

source 'https://rails-assets.org' do
	gem 'rails-assets-jquery'
	gem 'rails-assets-bootstrap', '~> 2.3.0'
	gem 'rails-assets-magnific-popup'
end

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

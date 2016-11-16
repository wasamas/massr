source 'https://rubygems.org'

ruby '2.3.2'

gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-asset-pipeline', require: 'sinatra/asset_pipeline'
gem 'sprockets-helpers', '= 1.1.0'
gem 'uglifier'
gem 'yui-compressor'

gem 'puma'
gem 'haml', require: 'haml'
gem 'omniauth', require: 'omniauth'
gem 'omniauth-twitter', require: 'omniauth-twitter'
gem 'mongo_mapper', require: 'mongo_mapper'
gem 'activemodel', '~> 4.2'
gem 'bson_ext'
gem 'rack_csrf', require: 'rack/csrf'
gem 'mail', require: 'mail'
gem 'signet'
gem 'picasa'
gem 'twitter'
gem 'rmagick'
gem 'rack-session-mongo', require: 'rack-session-mongo'
gem 'dalli', require: 'dalli'
gem 'celluloid'

source 'https://rails-assets.org' do
	gem 'rails-assets-jquery'
	gem 'rails-assets-bootstrap', '~> 2.3.0'
	gem 'rails-assets-magnific-popup'
end

group :development, :test do
	gem 'rake'
	gem 'rspec'
	gem 'fuubar'
	gem 'sinatra-contrib', require: 'sinatra/reloader'
	gem 'pit', require: 'pit'
	gem 'pry'
	gem 'autotest'
	gem 'therubyracer'
end

group :production do
	gem 'newrelic_rpm'
end

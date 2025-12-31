source 'https://rubygems.org'

ruby '~> 4.0.0'

gem 'sinatra', '~> 3.2', require: 'sinatra/base'
gem 'sprockets', '~> 3.7'
gem 'sprockets-helpers'
gem 'uglifier'
gem 'yui-compressor'
gem 'sass'

gem 'puma', '~> 6.4'
gem 'hamlit', '~> 3.0', require: 'hamlit'
#gem 'omniauth', '~> 2.1', require: 'omniauth'
#gem 'omniauth-twitter', '~> 1.4', require: 'omniauth-twitter'
gem 'omniauth', require: 'omniauth'
gem 'omniauth-twitter',  require: 'omniauth-twitter'
gem 'mongoid', '~> 9.0', require: 'mongoid'
# gem 'bson_ext'  # Integrated into bson gem
gem 'rack_csrf', require: 'rack/csrf'
gem 'rack', '~> 2.2'
gem 'rack-ssl', require: 'rack/ssl'
gem 'mail', '~> 2.8', require: 'mail'
gem 'twitter', '~> 8.0'
gem 'gyazo'
gem 'httparty', '~> 0.22'
gem 'rmagick', '~> 6.0'
gem 'dalli', '~> 3.2', require: ['dalli', 'rack/session/dalli']
# gem 'celluloid'  # Replaced with concurrent-ruby
gem 'concurrent-ruby', '~> 1.3'
gem 'memcachier', require: 'memcachier'

# Rails Assets support has ended in 2020
# JavaScript files are now served from vendor/assets/javascripts
# To download required files, run:
#   mkdir -p vendor/assets/javascripts
#   curl -o vendor/assets/javascripts/jquery-2.0.3.min.js https://code.jquery.com/jquery-2.0.3.min.js
#   curl -o vendor/assets/javascripts/bootstrap-2.3.2.min.js https://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js
#   curl -o vendor/assets/javascripts/jquery.magnific-popup-1.1.0.min.js https://cdnjs.cloudflare.com/ajax/libs/magnific-popup/1.1.0/jquery.magnific-popup.min.js

group :development, :test do
	gem 'rake'
	gem 'guard-rspec'
	gem 'fuubar'
	gem 'sinatra-contrib', '~> 3.2', require: 'sinatra/reloader'
	gem 'dotenv', require: 'dotenv'
	gem 'pry'
	# gem 'therubyracer'  # Removed - use Node.js for JavaScript execution
end

group :production do
	gem 'newrelic_rpm'
end

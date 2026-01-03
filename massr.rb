# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/wasamas/massr
#
# Distributed under GPL

Bundler.require(:default, ENV['RACK_ENV'] || :development)
require 'json'

# Ruby 4.0 compatibility patch for CGI.parse
require_relative 'config/initializers/cgi_parse_patch'

require_relative 'plugins/logging'
require_relative 'plugins/async_request'

module Massr
	# definition of module of plugins
	module Plugin
		module Notify; end
		module Media;  end
		module Cache;  end
	end

	class App < Sinatra::Base
		set :haml, {format: :html5}

		# Sprockets 3.x configuration
		set :sprockets, Sprockets::Environment.new(root)
		set :assets_prefix, '/assets'
		set :digest_assets, (ENV['RACK_ENV'] == 'production')

		configure do
			sprockets.append_path(File.join(root, 'assets/js'))
			sprockets.append_path(File.join(root, 'assets/css'))

			if ENV['RACK_ENV'] == 'production'
				sprockets.css_compressor = :yui
				sprockets.js_compressor = Uglifier.new(harmony: true)
			end

			Sprockets::Helpers.configure do |config|
				config.environment = sprockets
				config.prefix = assets_prefix
				config.digest = digest_assets
				config.public_path = public_folder
			end
		end

		helpers do
			include Sprockets::Helpers
		end

		configure :production do
			require 'newrelic_rpm' if ENV['NEW_RELIC_LICENSE_KEY']

			Mail.defaults do # using sendgrid plugin
				delivery_method :smtp, {
					:address => 'smtp.sendgrid.net',
					:port => ENV['SENDGRID_PORT'] || 587,
					:domain => 'sendgrid.net',
					:user_name => ENV['SENDGRID_USERNAME'],
					:password => ENV['SENDGRID_PASSWORD'],
					:authentication => :plain,
					:enable_starttls_auto => true
				}
			end

			enable :logging
			Massr::Plugin::Logging.instance.level(Massr::Plugin::Logging::WARN)
		end

		configure :development, :test do
			# loading TWITTER_CONSUMER_ID and TWITTER_CONSUMER_SECRET,
			# GMAIL_USERNAME and GMAIL_PASSWORD
			Dotenv.load

			register Sinatra::Reloader
			also_reload './*.rb'
			also_reload './models/*.rb'
			also_reload './helpers/*.rb'

			disable :protection

			Mail.defaults do # using sendgrid plugin
				delivery_method :smtp, {
					address: 'smtp.gmail.com',
					port: '587',
					user_name: ENV['GMAIL_USERNAME'],
					password: ENV['GMAIL_PASSWORD'],
					:authentication => :plain,
					:enable_starttls_auto => true
				}
			end

			enable :logging
			Massr::Plugin::Logging.instance.level(Massr::Plugin::Logging::DEBUG)
		end

		Mongoid::load!('config/mongoid.yml')
		Mongoid.raise_not_found_error = false

		session_expire = 60 * 60 * 24 * 30 - 1
		memcache_servers = ENV['MEMCACHE_SERVERS'] || ENV['MEMCACHIER_SERVERS'] || 'localhost:11211'
		use Rack::Session::Dalli,
			memcache_server: memcache_servers,
			username: ENV['MEMCACHE_USERNAME'] || ENV['MEMCACHIER_USERNAME'],
			password: ENV['MEMCACHE_PASSWORD'] || ENV['MEMCACHIER_PASSWORD'],
			expire_after: session_expire

		# CSRF protection is handled by Rack::Csrf, so disable OmniAuth's own CSRF protection
		twitter_id = ENV['TWITTER_CONSUMER_ID']
		twitter_secret = ENV['TWITTER_CONSUMER_SECRET']
		use OmniAuth::Builder do
			configure do |config|
				config.full_host = ENV['FULL_HOST'] if ENV['FULL_HOST']
				config.allowed_request_methods = [:post, :get]
				config.silence_get_warning = true
				config.request_validation_phase = proc {}
			end
			provider :twitter, twitter_id, twitter_secret
		end

		# WebAuthn configuration
		WebAuthn.configure do |config|
			config.allowed_origins = [ENV['WEBAUTHN_ORIGIN']]
			config.rp_name = ENV['WEBAUTHN_RP_NAME'] 
			config.algorithms = ['ES256', 'RS256']
			config.credential_options_timeout = 60_000
		end

		use Rack::Csrf

		# max entries of 1st view
		$limit = 20
	end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'

Massr::App::run! if __FILE__ == $0

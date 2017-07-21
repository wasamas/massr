# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL

Bundler.require(:default, ENV['RACK_ENV'] || :development)
require 'json'

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
		set :haml, { format: :html5, escape_html: true }

		set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg)
		set :assets_css_compressor, :yui
		set :assets_js_compressor, :uglifier
		set :assets_paths, %w(assets/js assets/css)
		register Sinatra::AssetPipeline
		RailsAssets.load_paths.each do |path|
			settings.sprockets.append_path(path)
		end

		configure :production do
			require 'newrelic_rpm' if ENV['NEW_RELIC_LICENSE_KEY']

			Mail.defaults do # using sendgrid plugin
				delivery_method :smtp, {
					:address => 'smtp.sendgrid.net',
					:port => '587',
					:domain => 'heroku.com',
					:user_name => ENV['SENDGRID_USERNAME'],
					:password => ENV['SENDGRID_PASSWORD'],
					:authentication => :plain,
					:enable_starttls_auto => true
				}
			end

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

			Massr::Plugin::Logging.instance.level(Massr::Plugin::Logging::DEBUG)
		end

		Mongoid::load!('config/mongoid.yml')
		Mongoid.raise_not_found_error = false

		session_expire = 60 * 60 * 24 * 30 - 1
		use Rack::Session::Dalli, cache: Dalli::Client.new, expire_after: session_expire

		twitter_id = ENV['TWITTER_CONSUMER_ID']
		twitter_secret = ENV['TWITTER_CONSUMER_SECRET']
		use(OmniAuth::Strategies::Twitter, twitter_id, twitter_secret)

		use Rack::Csrf

		# max entries of 1st view
		$limit = 20
	end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'

Massr::App::run! if __FILE__ == $0

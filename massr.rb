# -*- coding: utf-8; -*-
#
# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

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
		register Sinatra::AssetPipeline
		if defined?(RailsAssets)
			RailsAssets.load_paths.each do |path|
				settings.sprockets.append_path(path)
			end
		end

		DB = nil
		configure :production do

			require 'newrelic_rpm' if ENV['NEW_RELIC_LICENSE_KEY']

			@auth_twitter  = {
				:id => ENV['TWITTER_CONSUMER_ID'],
				:secret => ENV['TWITTER_CONSUMER_SECRET']
			}

			begin
				uri = URI.parse(ENV['MONGODB_URI'] || ENV['MONGOLAB_URI'])
				MongoMapper.connection = Mongo::Connection.from_uri(uri.to_s)
				db_name = uri.path.gsub(/^\//, '')
				MongoMapper.database = db_name
				DB = MongoMapper.connection.db(db_name)
			rescue Mongo::ConnectionFailure
			end

			Mail.defaults do # using sendgrid plugin
				delivery_method :smtp, {
					:address => 'smtp.sendgrid.net',
					:port => ENV['SENDGRID_PORT'] || 587,
					:domain => 'wasamas.net',
					:user_name => ENV['SENDGRID_USERNAME'],
					:password => ENV['SENDGRID_PASSWORD'],
					:authentication => :plain,
					:enable_starttls_auto => true
				}
			end

			Massr::Plugin::Logging.instance.level(Massr::Plugin::Logging::WARN)
		end

		configure :development, :test do
			Bundler.require :development
			register Sinatra::Reloader

			disable :protection

			@auth_twitter = Pit::get( 'auth_twitter', :require => {
					:id => 'your CONSUMER KEY of Twitter APP.',
					:secret => 'your CONSUMER SECRET of Twitter APP.',
				} )

			MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
			db_name = 'massr'
			MongoMapper.database = db_name
			DB = MongoMapper.connection.db(db_name)

			auth_gmail = Pit::get( 'Gmail', :require => {
				'mail' => 'Your Gmail address',
				'pass' => 'Your Gmail Password'
			} )
			Mail.defaults do # using sendgrid plugin
				delivery_method :smtp, {
					address: 'smtp.gmail.com',
					port: '587',
					user_name: auth_gmail['mail'],
					password: auth_gmail['pass'],
					:authentication => :plain,
					:enable_starttls_auto => true
				}
			end

			Massr::Plugin::Logging.instance.level(Massr::Plugin::Logging::DEBUG)
		end

		use(
			Rack::Session::Mongo,{
				:db => DB,
				:expire_after => 6 * 30 * 24 * 60 * 60,
				:secret => ENV['SESSION_SECRET']
			}) if DB

		OmniAuth.config.full_host = ENV['FULL_HOST'] if ENV['FULL_HOST']
		use(
			OmniAuth::Strategies::Twitter,
			@auth_twitter[:id],
			@auth_twitter[:secret])

		use Rack::Csrf

		#表示エントリ数
		$limit = 20

	end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'

Massr::App::run! if __FILE__ == $0

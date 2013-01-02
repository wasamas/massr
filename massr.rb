# -*- coding: utf-8; -*-
#
# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

require 'sinatra/base'
require 'haml'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'rack/csrf'
require 'mongo_mapper'
require 'rack-session-mongo'
require 'mail'

require_relative 'plugins/picasa'

module Massr
	module Plugin
	end

	class App < Sinatra::Base
		set :haml, { format: :html5, escape_html: true }

		configure :production do
         @auth_twitter  = {
				:id => ENV['TWITTER_CONSUMER_ID'],
				:secret => ENV['TWITTER_CONSUMER_SECRET']
			}

			uri = URI.parse(ENV['MONGOLAB_URI'])
			MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
			MongoMapper.database = uri.path.gsub(/^\//, '')

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

			Massr::Plugin::Picasa.auth(ENV['PICASA_ID'], ENV['PICASA_PASS']) if ENV['PICASA_ID']
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
			MongoMapper.database = 'massr'

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

			Massr::Plugin::Picasa.auth(auth_gmail['mail'], auth_gmail['pass'])
		end

		use(
			Rack::Session::Mongo,{
				:host => MongoMapper.connection.host,
				:db_name => MongoMapper.database.name,
				:expire_after => 6 * 30 * 24 * 60 * 60,
				:secret => ENV['SESSION_SECRET']
			})

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

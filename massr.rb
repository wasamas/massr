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
require 'mongo_mapper'

module Massr
	class App < Sinatra::Base
		enable :sessions
		set :haml, { format: :html5, escape_html: true }

		configure :production do
         @auth_twitter  = {
				:id => ENV['TWITTER_CONSUMER_ID'],
				:secret => ENV['TWITTER_CONSUMER_SECRET']
			}

			uri = URI.parse(ENV['MONGOHQ_URL'])
			MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
			MongoMapper.database = uri.path.gsub(/^\//, '')
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
		end

		use(
			OmniAuth::Strategies::Twitter,
			@auth_twitter[:id],
			@auth_twitter[:secret])

		use(
			Rack::Session::Cookie,
			:expire_after => 6 * 30 * 24 * 60 * 60,
			:secret => ENV['SESSION_SECRET'])

		#表示エントリ数
		$limit = 20
	end
end

require_relative 'models/init'
require_relative 'routes/init'

Massr::App::run! if __FILE__ == $0

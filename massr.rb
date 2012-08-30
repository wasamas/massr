# -*- coding: utf-8; -*-
#
# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by wasam@s production
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

$:.unshift './lib'
require 'massr/models'

module Massr

	class App < Sinatra::Base

		set :haml, { format: :html5, escape_html: true }

		configure :development do
			Bundler.require :development
			register Sinatra::Reloader

			@auth_twitter = Pit::get( 'auth_twitter', :require => {
					:id => 'your CUNSUMER KEY of Twitter APP.',
					:secret => 'your CUNSUMER SECRET of Twitter APP.',
				} )
			
			MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
			MongoMapper.database = 'massr'

		end

		configure :production do
         @auth_twitter  = {:id => ENV['TWITTER_CONSUMER_ID'], :secret => ENV['TWITTER_CONSUMER_SECRET']}

			uri = URI.parse(ENV['MONGOHQ_URL'])
			MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
			MongoMapper.database = uri.path.gsub(/^\//, '')

		end

		use OmniAuth::Strategies::Twitter  , @auth_twitter[:id]  , @auth_twitter[:secret]
		use Rack::Session::Cookie,:expire_after => 3600, :secret => ENV['SESSION_SECRET']

		enable :sessions

		get '/' do
			haml :index
		end

		get '/login' do
			redirect '/auth/twitter'
		end

		get '/logout' do
			session.clear
			redirect '/'
		end

		get '/auth/twitter/callback' do
			info = request.env['omniauth.auth']

			session[:twitter_name] = info['extra']['raw_info']['name']
			session[:twitter_id]   = info['extra']['raw_info']['screen_name']
			##session[:twitter_icon] = info['extra']['raw_info']['profile_background_image_url']
		end

		after '/auth/twitter/callback' do
			##登録済みチェック
			p user = User.first(:twitter_id => session[:twitter_id])
			if user != nil
				session[:user] = user
				redirect '/'
			else
				redirect '/user'
			end
		end

		get '/user' do
			haml :user
		end

		post '/user' do
			user = session[:user]
			user = user ? user : User.new

			user[:massr_id]   = request[:id]
			user[:twitter_id] = session[:twitter_id]
			user[:name]       = request[:name]
			user[:email]      = request[:email]

			if user.save!
				session[:user] = user
			end

			redirect '/'
		end
	end
end

Massr::App::run! if __FILE__ == $0

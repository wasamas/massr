# -*- coding: utf-8; -*-
#
# massr.rb : Massr - Mini Wassr
#
# Copyright (C) 2012 by TADA Tadashi <t@tdtds.jp>
#

require 'sinatra/base'
require 'haml'
require 'json'
require 'omniauth'
require 'omniauth-twitter'

require 'mongo_mapper'
require './lib/models/user'

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
		end

		use OmniAuth::Strategies::Twitter  , @auth_twitter[:id]  , @auth_twitter[:secret]
		use Rack::Session::Cookie,:expire_after => 3600, :secret => ENV['SESSION_SECRET']

		enable :sessions
				
		get '/' do
			haml :index
		end

		get '/auth/:provider/callback' do
			info = request.env['omniauth.auth']

			session[:twitter_name] = info['extra']['raw_info']['name']
			session[:twitter_id]   = info['extra']['raw_info']['screen_name']
			session[:twitter_icon] = info['extra']['raw_info']['profile_background_image_url']
			redirect '/user'
		end

		before '/user' do
			session[:twitter_id]
			
			##登録済みチェック
			if Models::User.all(:twitter_id => session[:twitter_id]).size > 0
				redirect '/'
			end
			
		end

		get '/user' do
			haml :user 
		end

		post '/user' do
			user = Models::User.new(
				:massr_id   => request[:id],
				:twitter_id => session[:twitter_id],
				:name       => request[:name],
				:email      => request[:email])
			user.save
			redirect '/'
		end
		
	end
end

Massr::App::run! if __FILE__ == $0

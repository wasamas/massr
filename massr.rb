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

		configure :development, :test do
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

		before do
			case request.path
			when '/login'
			when %r|^/auth/|
			when '/user'
				redirect '/login' unless session[:twitter_id]
			else
				redirect '/login' unless session[:user]
			end
		end

		get '/' do
			haml :index , :locals => {:entries => Entry.sort(:created_at.desc).limit(50) }
		end

		get '/login' do
			haml :login
		end

		get '/logout' do
			session.clear
			redirect '/'
		end

		get '/auth/twitter/callback' do
			info = request.env['omniauth.auth']
			session[:twitter_name] = info['extra']['raw_info']['name']
			session[:twitter_id]   = info['extra']['raw_info']['screen_name']
			session[:twitter_icon_url] = info['extra']['raw_info']['profile_image_url']
		end

		after '/auth/twitter/callback' do
			##登録済みチェック
			user = User.find_by_twitter_id(session[:twitter_id])
			if user
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
			request[:twitter_id] = session[:twitter_id]
			request[:twitter_icon_url] = session[:twitter_icon_url]
			if user
				user.update_profile(request)
			else
				session[:user] = User.create_by_registration_form( request )
			end

			redirect '/'
		end

		post '/entry' do
			entry = Entry.new
			entry.update_entry( request, session ) unless request[:body].size==0
			redirect '/'
		end
		
		post '/entry/:id/like' do
			user = session[:user]
			entry = Entry.find_by_id(params[:id])
			unless ((entry.likes.map{|like| like.user._id == user._id  }).include? true)
				like = Like.new(:user => user)
				entry.likes << like
				entry.save!
			end
			redirect '/'
		end

	end
end

Massr::App::run! if __FILE__ == $0

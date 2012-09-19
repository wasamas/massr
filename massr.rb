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

$:.unshift './lib'
require 'massr/models'

module Massr

	class App < Sinatra::Base

		set :haml, { format: :html5, escape_html: true }

		configure :development, :test do
			Bundler.require :development
			register Sinatra::Reloader

			disable :protection

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
		use Rack::Session::Cookie,:expire_after => 6 * 30 * 24 * 60 * 60 , :secret => ENV['SESSION_SECRET']

		#表示エントリ数
		$limit = 20

		enable :sessions

		before do
			case request.path
			when '/unauthorized'
			when '/login'
			when '/logout'
			when %r|^/auth/|
			when '/user'
				redirect '/login' unless session[:twitter_id]
			else
				unless session[:user_id]
					redirect '/login'
				else
					user =  User.find_by_id(session[:user_id])
					redirect '/logout' unless user
					redirect '/unauthorized' unless user.authorized?
				end
			end
		end

		get '/' do
			page = params[:page]?params[:page]:1
			haml :index , :locals => {:page => page , :statements => Statement.get_statements(page)}
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
				session[:user_id] = user._id
				redirect '/'
			else
				redirect '/user'
			end
		end

		get '/users.html' do
			haml :users , :locals => { :users => User.sort(:created_at.desc) }
		end

		get '/user' do
			haml :user
		end

		get '/user/:massr_id' do
			user = User.find_by_massr_id(params[:massr_id])
			page = params[:page]?params[:page]:0
			haml :user_statements , :locals => {:page=>page,:statements => Statement.get_statements(page,{:user_id => user.id}) }		   
		end

		post '/user' do
			user = User.find_by_id(session[:user_id])
			request[:twitter_id] = session[:twitter_id]
			request[:twitter_icon_url] = session[:twitter_icon_url]
			if user
				user.update_profile(request)
			else
				user = User.create_by_registration_form( request )
				session[:user_id] = user._id
			end

			redirect '/'
		end

		delete '/user' do
			user = User.find_by_id(session[:user_id])
			user.destroy
			session.clear
			redirect '/'
		end

		post '/statement' do
			statement = Statement.new
			request[:user] = User.find_by_id(session[:user_id])
			statement.update_statement( request ) unless request[:body].size==0
			redirect '/'
		end
		
		get '/statement/:id' do
			haml :user_statement, :locals => {:statement => Statement.find_by_id(params[:id])}
		end

		delete '/statement/:id' do
			Statement.destroy(params[:id])
			redirect '/'
		end

		before '/statement/:id/like' do
			@user = User.find_by_id(session[:user_id])
			@statement = Statement.find_by_id(params[:id])
		end
		
		post '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			unless ((@statement.likes.map{|like| like.user._id == @user._id  }).include? true)
				like = Like.new(:user => @user)
				@statement.likes << like
			end
			@statement.save!
			redirect '/'
		end

		delete '/statement/:id/like' do
			@statement.likes.delete_if{ |like| !like.user}
			@statement.likes.delete_if{ |like| like.user.id == @user._id}
			@statement.save!
			redirect '/'
		end
		
		post '/search' do
			page = params[:page]?params[:page]:1
			haml :index , :locals => {
				:page => page , 
				:statements => Statement.get_statements(page,{:body=>/.*#{params[:search]}.*/})}
		end

		before '/admin*' do
			user =  User.find_by_id(session[:user_id])
			redirect '/' unless user.admin?
		end
		
		get '/admin' do
			haml :admin, :locals => {:users => User.where(:_id => {:$ne => session[:user_id]}) }
		end

		put '/user/:massr_id' do
			user =  User.find_by_id(session[:user_id])
			redirect '/' unless user.admin?
			User.change_status(params[:massr_id],params[:status])
		end

		get '/unauthorized' do
			haml :unauthorized
		end

	end
end

Massr::App::run! if __FILE__ == $0

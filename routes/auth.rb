# -*- coding: utf-8; -*-
#
# routes/auth.rb : login, logout and auth
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
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

		get '/unauthorized' do
			haml :unauthorized
		end
	end
end

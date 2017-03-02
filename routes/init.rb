# -*- coding: utf-8; -*-
#
# routes/init.rb : initialize routes
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#

module Massr
	class App < Sinatra::Base
		before do
			cache.delete('main') unless request.get?
			cache.set('stamp', Stamp.get_stamps.map{|i| i.to_hash}) unless cache.get('stamp')

			case request.path
			when '/unauthorized'
			when '/login'
			when '/logout'
			when %r|^/auth/|
			when '/user'
				redirect '/login' unless session[:twitter_user_id]
			else
				unless session[:user_id]
					redirect '/login'
				else
					user =	User.find_by(id: session[:user_id])
					redirect '/logout' unless user
					redirect '/logout' if user.twitter_user_id == nil && user.twitter_id != session[:twitter_id]
					redirect '/logout' unless session[:twitter_icon_url_https]
					redirect '/user?update=true' unless user.twitter_user_id
					redirect '/user?update=true' unless user.twitter_icon_url_https
					redirect '/unauthorized' unless user.authorized?
				end
			end
		end

		not_found do
			haml :not_found
		end
	end
end

require_relative 'main'
require_relative 'auth'
require_relative 'statement'
require_relative 'stamp'
require_relative 'user'
require_relative 'admin'
require_relative 'search'
require_relative 'icon'

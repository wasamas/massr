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
			clear_cache unless request.get?

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

		not_found do
			haml :not_found
		end
	end
end

require_relative 'main'
require_relative 'auth'
require_relative 'statement'
require_relative 'user'
require_relative 'admin'
require_relative 'search'
